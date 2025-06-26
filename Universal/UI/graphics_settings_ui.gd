extends Control

@export_group("Options")
@export var screen: OptionButton
@export var filter: OptionButton
@export var fsr: Slider
@export var vsync: OptionButton
@export var fxaa: OptionButton
@export var taa: OptionButton
@export var msaa: OptionButton
@export var shadowRes: OptionButton
@export var shadowFil: OptionButton
@export var lod: OptionButton
@export var sdfgi: OptionButton
@export var ssao: OptionButton
@export var ssil: OptionButton
@export var mirror: OptionButton
@export_group("FSR")
@export var fsr_label: Label

func _ready() -> void:
	# update all values (hell :))
	screen.selected    = GraphicsSettings.window_conf
	filter.selected    = GraphicsSettings.filter_conf
	fsr.value          = GraphicsSettings.fsr_conf
	vsync.selected     = GraphicsSettings.vsync_conf
	fxaa.selected      = GraphicsSettings.fxaa_conf
	taa.selected       = GraphicsSettings.taa_conf
	msaa.selected      = GraphicsSettings.msaa_conf
	shadowRes.selected = GraphicsSettings.shadow_res
	shadowFil.selected = GraphicsSettings.shadow_filter
	lod.selected       = GraphicsSettings.lod_conf
	sdfgi.selected     = GraphicsSettings.sdfgi_conf
	ssao.selected      = GraphicsSettings.ssao_conf
	ssil.selected      = GraphicsSettings.ssil_conf
	mirror.selected    = GraphicsSettings.mirror_conf
	
	# attach signals (ahhhhh)
	screen.item_selected.connect(GraphicsSettings.change_window_mode)
	filter.item_selected.connect(GraphicsSettings.change_filter)
	fsr.value_changed.connect(GraphicsSettings.change_fsr)
	vsync.item_selected.connect(GraphicsSettings.change_vsync)
	fxaa.item_selected.connect(GraphicsSettings.change_fxaa)
	taa.item_selected.connect(GraphicsSettings.change_taa)
	msaa.item_selected.connect(GraphicsSettings.change_msaa)
	shadowRes.item_selected.connect(GraphicsSettings.change_shadow_resolution)
	shadowFil.item_selected.connect(GraphicsSettings.change_shadow_filter)
	lod.item_selected.connect(GraphicsSettings.change_lod)
	sdfgi.item_selected.connect(GraphicsSettings.change_sdfgi)
	ssao.item_selected.connect(GraphicsSettings.change_ssao)
	ssil.item_selected.connect(GraphicsSettings.change_ssil)
	mirror.item_selected.connect(GraphicsSettings.change_mirror)

	GraphicsSettings.update_everything()

	filter.item_selected.connect(filter_changed)
	filter_changed(filter.selected)
	
func filter_changed(index: int) -> void:
	if index == 0:
		fsr_label.visible = false
		fsr.visible = false
	if index == 1: # FSR
		fsr_label.visible = true
		fsr.visible = true
		