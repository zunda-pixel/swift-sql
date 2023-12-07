import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

public struct SQLModelMacro: MemberAttributeMacro, MemberMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    guard let attachedTypeNameSyntax = declaration.as(StructDeclSyntax.self)?.name ??
            declaration.as(ClassDeclSyntax.self)?.name ??
            declaration.as(ActorDeclSyntax.self)?.name
    else {
      throw Diagnostics.appliedTypeFail
    }

    let variableDeclarations = declaration.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }

    guard !variableDeclarations.isEmpty else {
      return []
    }
    
    let syntax = VariableDeclSyntax(
      modifiers: DeclModifierListSyntax {
        DeclModifierSyntax(name: .keyword(.static))
        DeclModifierSyntax(name: .keyword(.public))
      },
      bindingSpecifier: .keyword(.let)
    ) {
      PatternBindingSyntax(
        pattern: PatternSyntax("fields"),
        typeAnnotation: TypeAnnotationSyntax(
          type: DictionaryTypeSyntax(
            key: IdentifierTypeSyntax(
              name: .identifier("PartialKeyPath"),
              genericArgumentClause: GenericArgumentClauseSyntax(
                arguments: GenericArgumentListSyntax {
                  GenericArgumentSyntax(
                    argument: IdentifierTypeSyntax(name: .identifier(attachedTypeNameSyntax.text))
                  )
                }
              )
            ),
            value: SomeOrAnyTypeSyntax(
              someOrAnySpecifier: .keyword(.any),
              constraint: MetatypeTypeSyntax(
                baseType: IdentifierTypeSyntax(name: .identifier("Fiedable")),
                metatypeSpecifier: .keyword(.Type)
              )
            )
          )
        ),
        initializer: InitializerClauseSyntax(equal: .equalToken(), value: DictionaryExprSyntax {
          DictionaryElementListSyntax {
            for (type, name) in variableDeclarations
              .filter({ Self.validStoredPeoperty(member: $0 )})
              .flatMap(\.bindings)
              .compactMap({ member -> (String, String)? in
                guard let propertyName = member.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { return nil }
                let typeName = member.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name.text
                if let typeName {
                  return (typeName, propertyName)
                } else {
                  // Nothing Type Annotation
                  guard let initializerValue = member.initializer?.value else { return nil }
                  if initializerValue.is(BooleanLiteralExprSyntax.self) {
                    return (String(describing: Bool.self), propertyName)
                  } else if initializerValue.is(StringLiteralExprSyntax.self) {
                    return (String(describing: String.self), propertyName)
                  } else if initializerValue.is(IntegerLiteralExprSyntax.self) {
                    return (String(describing: Int.self), propertyName)
                  } else if initializerValue.is(FloatLiteralExprSyntax.self) {
                    return (String(describing: Double.self), propertyName)
                  } else {
                    return nil
                  }
                }
              }) {
                DictionaryElementSyntax(
                  key: KeyPathExprSyntax(components: KeyPathComponentListSyntax([
                    KeyPathComponentSyntax(
                      period: .periodToken(),
                      component: .init(
                      KeyPathPropertyComponentSyntax(
                        declName: DeclReferenceExprSyntax(baseName: .identifier(name))
                      )
                    )),
                  ])),
                  value: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: .identifier(type)),
                    declName: DeclReferenceExprSyntax(baseName: .identifier("self"))
                  )
                )
              }
          }
        })
      )
    }
    
    return [
      DeclSyntax(syntax),
    ]
  }
  
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.AttributeSyntax] {
    guard let variableDesclSyntax = member.as(VariableDeclSyntax.self) else { return [] }
    
    guard Self.validStoredPeoperty(member: variableDesclSyntax) else { return [] }
    
    return [
      AttributeSyntax(
        attributeName: IdentifierTypeSyntax(
          name: .identifier("Field")
        )
      )
    ]
  }
  
  private static func validStoredPeoperty(member: VariableDeclSyntax) -> Bool {
    // Ignore ComputerProperty
    guard member.bindings.allSatisfy({ $0.accessorBlock == nil }) else { return false }

    // Get All Attribute Name
    let containsModelIgnoredAttribute = member.attributes
      .compactMap({ if case .attribute(let attributeSyntax) = $0 { attributeSyntax } else { nil }})
      .compactMap({ $0.attributeName.as(IdentifierTypeSyntax.self) })
      .map { $0.name.text }
      .contains("ModelIgnored")

    // If member has ModelIgnored Attribute, return false
    if containsModelIgnoredAttribute {
      return false
    }

    return true
  }
}
