{{ row . `win('field') -> 'win';` }}
win(_) -> [].

{{ row . `lose('field') -> 'lose';` }}
lose(_) -> [].