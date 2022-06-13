{{- with (sort . "task" false) }}
{{- with (filter . `gt task 0`) }}
{{ scol . `open_by_task('task') -> [{"'id'@'sub_id'",'level'}];` "id,sub_id" false }}
open_by_task(_) -> [].
{{ end }}
{{- end }}

{{- with (sort . "level" false) }}
{{ with (filter . `gt level 0`) }}
{{ scol . `open_by_level('level') -> [{"'id'@'sub_id'",'task'}];` "id,sub_id" false }}
open_by_level(_) -> [].
{{ end }}
{{- end }}

{{ with (filter . `ne module undefined`) }}

{{- row . `mod("'id'@'sub_id'") -> 'module';` }}
mod(_) -> undefined.

{{ row . `sysid('module') -> "'id'@'sub_id'";` }}
sysid(_) -> undefined.

{{- end }}

{{ with (filter . `ne mail 0`) }}

{{- row . `mail("'id'@'sub_id'") -> {'mail', 'mail_reward'};` }}
mail(_) -> {0, []}.

{{- end }}

{{ scol . `syslist() -> [
{"'id'@'sub_id'",'level','task'}].` "id,sub_id" false }}
