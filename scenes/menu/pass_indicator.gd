extends Panel

func set_pass(val:bool):
	$Panel2.visible = val
func is_pass_set() -> bool:
	return $Panel2.visible
