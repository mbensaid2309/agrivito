class AgricultureError(RuntimeError):
    pass


class ResourceNotFoundError(AgricultureError):
    pass


class ResourceConflictError(AgricultureError):
    pass
