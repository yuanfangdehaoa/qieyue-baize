{{ row . `reward(local, 'rank') -> 'reward';` }}
{{ row . `reward(cross, 'rank') -> 'cross_reward';` }}
reward(_, _) -> [].

{{ row . `mail_reward(local, 'rank') -> 'mail_reward';` }}
{{ row . `mail_reward(cross, 'rank') -> 'cross_mail_reward';` }}
mail_reward(_, _) -> [].

{{ row . `final_mail_reward(local, 'rank') -> 'final_mail_reward';` }}
{{ row . `final_mail_reward(cross, 'rank') -> 'cross_final_mail_reward';` }}
final_mail_reward(_, _) -> [].