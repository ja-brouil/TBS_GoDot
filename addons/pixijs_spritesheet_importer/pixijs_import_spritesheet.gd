# The MIT License (MIT)
#
# Copyright (c) 2018 Andreas Loew / CodeAndWeb GmbH www.codeandweb.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

tool
extends EditorImportPlugin

var imageLoader = preload("image_loader.gd").new();

enum Preset { PRESET_DEFAULT }

func get_importer_name():
    return "pixijs_import_spritesheet"


func get_visible_name():
    return "PixiJS SpriteSheet"


func get_recognized_extensions():
    return ["js", "json"]


func get_save_extension():
    return "res"


func get_resource_type():
    return "Resource"


func get_preset_count():
    return Preset.size()


func get_preset_name(preset):
    match preset:
        Preset.PRESET_DEFAULT: return "Default"


func get_import_options(preset):
    return []


func get_option_visibility(option, options):
    return true


func get_import_order():
    return 200


func import(source_file, save_path, options, r_platform_variants, r_gen_files):
    print("Importing sprite sheet from "+source_file);
    
    var sheets = read_sprite_sheet(source_file)
    var sheetFolder = source_file.get_basename()+".sprites"
    create_folder(sheetFolder)
        
    var sheetFile = source_file.get_base_dir()+"/"+ sheets.meta.image 
    var image = load_image(sheetFile, "ImageTexture", [])
    create_atlas_textures(sheetFolder, sheets, image, r_gen_files)

    return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], Resource.new())
func create_folder(folder):
    var dir = Directory.new()
    if !dir.dir_exists(folder):
        if dir.make_dir_recursive(folder) != OK:
            printerr("Failed to create folder: " + folder)
    
    
func create_atlas_textures(sheetFolder, sheet, image, r_gen_files):
    for sprite_name in sheet.frames:
        var sprite = sheet.frames[sprite_name]
        if !create_atlas_texture(sheetFolder, sprite, sprite_name, image, r_gen_files):
            return false
    return true


func create_atlas_texture(sheetFolder, sprite, sprite_name, image, r_gen_files):
    var texture = AtlasTexture.new()
    texture.atlas = image
    var name = sheetFolder+"/"+sprite_name.get_basename()+".tres"
    texture.region = Rect2(sprite.frame.x, sprite.frame.y, sprite.frame.w, sprite.frame.h)
    texture.margin = Rect2(sprite.spriteSourceSize.x, sprite.spriteSourceSize.y, sprite.sourceSize.w - sprite.frame.w, sprite.sourceSize.h - sprite.frame.h)
    r_gen_files.push_back(name)
    return save_resource(name, texture)


func save_resource(name, texture):
    create_folder(name.get_base_dir())
    
    var status = ResourceSaver.save(name, texture)
    if status != OK:
        printerr("Failed to save resource "+name)
        return false
    return true


func read_sprite_sheet(fileName):
    var file = File.new()
    if file.open(fileName, file.READ) != OK:
        printerr("Failed to load "+fileName)
    var text = file.get_as_text()
    var dict = JSON.parse(text).result
    if !dict:
        printerr("Invalid json data in "+fileName)
    file.close()
    return dict


func load_image(rel_path, source_path, options):
    return imageLoader.load_image(rel_path, source_path, options)
