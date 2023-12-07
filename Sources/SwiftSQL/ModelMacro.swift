import SQLModelMacro

@attached(
  member,
  names: named(fields), named(name)
) @attached(
  memberAttribute
) public macro Model() = #externalMacro(
  module: "SQLModelMacro",
  type: "SQLModelMacro"
)
