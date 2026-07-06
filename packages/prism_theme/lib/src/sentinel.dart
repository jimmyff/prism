/// A sentinel distinguishing "argument omitted" from "argument set to null" in
/// `copyWith` methods, so passing `null` genuinely clears a nullable field.
///
/// Package-internal: imported by the `copyWith` implementations that need to
/// clear fields, and deliberately **not** exported from the `prism_theme`
/// barrel. Shared (one instance) rather than duplicated per class.
const Object unset = Object();
