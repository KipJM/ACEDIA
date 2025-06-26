extends RichTextLabel

func meta_clicked(meta) -> void:
	OS.shell_open(meta)
