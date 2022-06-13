{{ row . `find('new_scene_type') -> {
	'valid_cur_scene_types',
	'valid_change_types',
	'invalid_role_states'
};` }}
find(_) -> undefined.
