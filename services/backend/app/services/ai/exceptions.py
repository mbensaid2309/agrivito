class AIServiceError(RuntimeError):
    public_message = "L'analyse est temporairement indisponible."


class AIConfigurationError(AIServiceError):
    public_message = "Le service de diagnostic n'est pas configuré."


class AIProviderTimeoutError(AIServiceError):
    public_message = "Le service de diagnostic a dépassé le délai autorisé."


class AIProviderRateLimitError(AIServiceError):
    public_message = "Le service de diagnostic est temporairement saturé."


class AIProviderUnavailableError(AIServiceError):
    public_message = "Le service de diagnostic est temporairement indisponible."


class AIInvalidResponseError(AIServiceError):
    public_message = "La réponse du service de diagnostic est invalide."


class DiscoveryLimitReachedError(AIServiceError):
    public_message = "Vous avez atteint la limite du mode découverte."
