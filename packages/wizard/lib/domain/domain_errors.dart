sealed class WizardDomainError {
  const WizardDomainError();
}

class InvalidNsecError extends WizardDomainError {
  const InvalidNsecError(this.message);
  final String message;
}

class InvalidRelayUrlError extends WizardDomainError {
  const InvalidRelayUrlError(this.url);
  final String url;
}
