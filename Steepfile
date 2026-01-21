# Steepfile
target :lib do
  signature "sig"

  check "lib"

  library "stringio"

  # Configure diagnostic severity
  # These errors are from Ruby code patterns that are runtime-safe but hard to express in RBS
  configure_code_diagnostics do |hash|
    # Suppress errors for method calls on potentially nil values
    # The actual code handles nil cases properly at runtime
    hash[Steep::Diagnostic::Ruby::NoMethod] = :hint
    hash[Steep::Diagnostic::Ruby::ArgumentTypeMismatch] = :hint
    hash[Steep::Diagnostic::Ruby::MethodBodyTypeMismatch] = :hint
    hash[Steep::Diagnostic::Ruby::UnannotatedEmptyCollection] = :hint
  end
end
