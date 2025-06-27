extends Node

# This script is the main reason I'm hesitant to make the project open source :)

# Video settings.
var filter_conf: int
var fsr_conf: float
var vsync_conf: int
var msaa_conf: int
var taa_conf: int
var fxaa_conf: int
var window_conf: int
var shadow_res: int
var shadow_filter: int
var lod_conf: int
var ssao_conf: int
var ssil_conf: int
var sdfgi_conf: int
var mirror_conf: int

var mirror_scale: float 

# Not graphics settings but too lazy to make another autoload
var first_start: bool

func _ready() -> void:
	filter_conf   = 0
	fsr_conf      = 0.2
	vsync_conf    = 0
	msaa_conf     = 2
	taa_conf      = 0
	fxaa_conf     = 0
	window_conf   = 2
	shadow_res    = 3
	shadow_filter = 2
	lod_conf      = 2
	ssao_conf     = 2
	ssil_conf     = 2
	sdfgi_conf    = 1
	mirror_conf   = 4
	first_start = true

func change_filter(index: int) -> void:
	filter_conf = index
	# Viewport scale mode setting.
	if index == 0: # Bilinear (Fastest)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0.
	elif index == 1: # FSR 1.0 (Fast)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0.


func change_fsr(value: float) -> void:
	fsr_conf = value
	# Lower FSR sharpness values result in a sharper image.
	# Invert the slider so that higher values result in a sharper image,
	# which is generally expected from users.
	get_viewport().fsr_sharpness = 2.0 - value


func change_vsync(index: int) -> void:
	vsync_conf = index
	# Vsync is enabled by default.
	# Vertical synchronization locks framerate and makes screen tearing not visible at the cost of
	# higher input latency and stuttering when the framerate target is not met.
	# Adaptive V-Sync automatically disables V-Sync when the framerate target is not met, and enables
	# V-Sync otherwise. This prevents suttering and reduces input latency when the framerate target
	# is not met, at the cost of visible tearing.
	if index == 0: # Disabled (default)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func change_msaa(index: int) -> void:
	msaa_conf = index
	# Multi-sample anti-aliasing. High quality, but slow. It also does not smooth out the edges of
	# transparent (alpha scissor) textures.
	if index == 0: # Disabled (default)
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif index == 1: # 2×
		get_viewport().msaa_3d = Viewport.MSAA_2X
	elif index == 2: # 4×
		get_viewport().msaa_3d = Viewport.MSAA_4X
	elif index == 3: # 8×
		get_viewport().msaa_3d = Viewport.MSAA_8X


func change_taa(index: int) -> void:
	taa_conf = index
	# Temporal antialiasing. Smooths out everything including specular aliasing, but can introduce
	# ghosting artifacts and blurring in motion. Moderate performance cost.
	get_viewport().use_taa = index == 1


func change_fxaa(index: int) -> void:
	fxaa_conf = index
	# Fast approximate anti-aliasing. Much faster than MSAA (and works on alpha scissor edges),
	# but blurs the whole scene rendering slightly.
	get_viewport().screen_space_aa = int(index == 1) as Viewport.ScreenSpaceAA


func change_window_mode(index: int) -> void:
	window_conf = index
	# To change between winow, fullscreen and other window modes,
	# set the root mode to one of the options of Window.MODE_*.
	# Other modes are maximized and minimized.
	if index == 0: # Disabled
		get_tree().root.set_mode(Window.MODE_WINDOWED)
	elif index == 1: # Fullscreen
		get_tree().root.set_mode(Window.MODE_FULLSCREEN)
	elif index == 2: # Exclusive Fullscreen (default)
		get_tree().root.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)


# Quality settings.

func change_shadow_resolution(index: int) -> void:
	shadow_res = index
	if index == 0: # Minimum
		RenderingServer.directional_shadow_atlas_set_size(512, true)
		# Disable positional (omni/spot) light shadows entirely to further improve performance.
		# These often don't contribute as much to a scene compared to directional light shadows.
		get_viewport().positional_shadow_atlas_size = 0
	if index == 1: # Very Low
		RenderingServer.directional_shadow_atlas_set_size(1024, true)
		get_viewport().positional_shadow_atlas_size = 1024
	if index == 2: # Low
		RenderingServer.directional_shadow_atlas_set_size(2048, true)
		get_viewport().positional_shadow_atlas_size = 2048
	if index == 3: # Medium (default)
		RenderingServer.directional_shadow_atlas_set_size(4096, true)
		get_viewport().positional_shadow_atlas_size = 4096
	if index == 4: # High
		RenderingServer.directional_shadow_atlas_set_size(8192, true)
		get_viewport().positional_shadow_atlas_size = 8192
	if index == 5: # Ultra
		RenderingServer.directional_shadow_atlas_set_size(16384, true)
		get_viewport().positional_shadow_atlas_size = 16384


func change_shadow_filter(index: int) -> void:
	shadow_filter = index
	if index == 0: # Very Low
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
	if index == 1: # Low
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
	if index == 2: # Medium (default)
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	if index == 3: # High
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	if index == 4: # Very High
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	if index == 5: # Ultra
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)


func change_lod(index: int) -> void:
	lod_conf = index
	if index == 0: # Low
		get_viewport().mesh_lod_threshold = 4.0
	if index == 1: # Medium
		get_viewport().mesh_lod_threshold = 2.0
	if index == 2: # High (default)
		get_viewport().mesh_lod_threshold = 1.0
	if index == 3: # Ultra
		# Always use highest LODs to avoid any form of pop-in.
		get_viewport().mesh_lod_threshold = 0.0

# Effect settings.

func change_ssao(index: int) -> void:
	ssao_conf = index
	if index == 0: # Very Low
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	if index == 1: # Low
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	if index == 2: # Medium
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
	if index == 3: # High
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)


func change_ssil(index: int) -> void:
	ssil_conf = index
	if index == 0: # Very Low
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
	if index == 1: # Low
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
	if index == 2: # Medium
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
	if index == 3: # High
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)


func change_sdfgi(index: int) -> void:
	sdfgi_conf = index
	if index == 0: # Low
		RenderingServer.gi_set_use_half_resolution(true)
	if index == 1: # High
		RenderingServer.gi_set_use_half_resolution(false)

func change_mirror(index: int) -> void:
	mirror_conf = index
	if index == 0:
		mirror_scale = 0.4
	if index == 1:
		mirror_scale = 0.65
	if index == 2:
		mirror_scale = 0.8
	if index == 3:
		mirror_scale = 0.9
	if index == 4:
		mirror_scale = 1.0
	if index == 5:
		mirror_scale = 1.1
		

func update_everything() -> void:
	change_filter(filter_conf)
	change_fsr(fsr_conf)
	change_vsync(vsync_conf)
	change_msaa(msaa_conf)
	change_taa(taa_conf)
	change_fxaa(fxaa_conf)
	change_window_mode(window_conf)
	change_shadow_resolution(shadow_res)
	change_shadow_filter(shadow_filter)
	change_lod(lod_conf)
	change_ssao(ssao_conf)
	change_ssil(ssil_conf)
	change_sdfgi(sdfgi_conf)
	change_mirror(mirror_conf)

# hell.
