$C98F#field::update_window_attr_buff#attr_buff@07c0
$CB6B#field::update_vram_by_07d0#07d0:vram high; 07e0:vram low; 07f0:value to load
$CAB1#field::merge_bg_attr_with_buff#attr_cache@0300 |= attr_buff@07c0
$ED61#field::get_window_metrics#
$ED56#field::init_window_attr_buffer#
$F8AA#do_sprite_dma_from_0200#
$FF00#thunk_waitNmiBySetHandler#
$EDE1#field::setBgScrollTo0#
$ECF5#field::restore_bank#
$ED02#field::draw_window_box#
$ECFA#field::draw_inplace_window#
$FF03#call_switch_2banks#
$EDC6#field::draw_window_row#
$C750#field::call_sound_driver#
$C9A9#field::set_bg_attr_for_window#
$F6AA#field::draw_window_contents#
$EDF6#field::get_window_top_tiles#
$EE9A#field::load_and_draw_string#
$EEC0#field::draw_string_in_window#
$EC18#field_hide_sprites_under_wind#
$F670#field::calc_size_and_init_buff#field_calc_draw_width_and_init_window_tile_buffer 
$ECE5#field::draw_window_top#
$F692#field::draw_window_content#render buffered (at $0780) content
$D281#field::get_pad_input#order of bits averse to those in battle
$D29A#field::mask_input?#
$FF36#await_nmi_by_set_handler#
$FF2A#nmi_handler_01#
$E571#field::sync_ppu_scroll_w_map#
$ECD8#field::advance_frame_w_sound#
$EE65#field::stream_string_in_window#
$FF06#call_switch_1st_bank#
$ECAB#field::await_and_get_new_input#
$ECC4#field::get_next_input#
$EBA9#field::seek_to_next_line#string pointer at $1c; on exit $3e have the same
$EEFA#field::decode_and_draw_string#
$F02A#field::map_opcodes_into_tiles#opcodes := [0x10, 0x28)
$EC83#field::show_message_UNK#
$EC8B#field::show_message_window#
$EC8D#field::show_window#
