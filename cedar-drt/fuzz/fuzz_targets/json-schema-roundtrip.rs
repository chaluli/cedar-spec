/*
 * Copyright Cedar Contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#![no_main]
use cedar_drt_inner::{fuzz_target, schemas::equivalence_check};

use cedar_policy_core::validator::json_schema;
use cedar_policy_core::{ast, extensions::Extensions};
use cedar_policy_generators::{
    schema::downgrade_frag_to_raw, schema::Schema, settings::ABACSettings,
};
use libfuzzer_sys::arbitrary::{self, Arbitrary, Unstructured};
use std::collections::BTreeMap;

#[derive(Debug, Clone)]
struct Input {
    pub schema: json_schema::Fragment<ast::InternalName>,
}

/// settings for this fuzz target
const SETTINGS: ABACSettings = ABACSettings {
    match_types: false,
    enable_extensions: true,
    max_depth: 3,
    max_width: 7,
    enable_additional_attributes: false,
    enable_like: true,
    // ABAC fuzzing restricts the use of action because it is used to generate
    // the corpus tests which will be run on Cedar and CedarCLI.
    // These packages only expose the restricted action behavior.
    enable_action_groups_and_attrs: false,
    enable_arbitrary_func_call: true,
    enable_unknowns: false,
    enable_action_in_constraints: true,
};

impl<'a> Arbitrary<'a> for Input {
    fn arbitrary(u: &mut Unstructured<'a>) -> arbitrary::Result<Self> {
        let arb_schema = Schema::arbitrary(SETTINGS.clone(), u)?;
        let namespace = arb_schema.schema;
        let name = arb_schema.namespace;

        let schema = json_schema::Fragment(BTreeMap::from([(name, namespace)]));

        Ok(Self { schema })
    }

    fn try_size_hint(
        depth: usize,
    ) -> arbitrary::Result<(usize, Option<usize>), arbitrary::MaxRecursionReached> {
        Schema::arbitrary_size_hint(depth)
    }
}

fuzz_target!(|i: Input| {
    let raw_schema = downgrade_frag_to_raw(i.schema);
    let json = serde_json::to_value(raw_schema.clone()).unwrap();
    let json_ast = json_schema::Fragment::from_json_value(json).unwrap();
    if let Err(e) = equivalence_check(&raw_schema, &json_ast) {
        panic!("JSON roundtrip failed: {e}\nOrig:\n```\n{raw_schema}\n```\nRoundtripped:\n```\n{json_ast}\n```");
    }
    let src = json_ast.to_cedarschema().unwrap();
    let (final_ast, _) =
        json_schema::Fragment::from_cedarschema_str(&src, Extensions::all_available()).unwrap();
    if let Err(e) = equivalence_check(&raw_schema, &final_ast) {
        panic!("Cedar roundtrip failed: {e}\nSrc:\n```\n{src}\n```");
    }
});
