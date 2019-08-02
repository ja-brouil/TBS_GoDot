# PixiJS Spritesheet Importer

This is a plugin for [Godot Engine](https://godotengine.org) to import `AtlasTexture`s from a spritesheet made for PixiJS.

These sheets can be generated using [ShoeBox](http://renderhjs.net/shoebox/) or [SpriteSheet Packer](https://amakaseev.github.io/sprite-sheet-packer/).

**Note: This is compatible only with Godot 3.0 or later.**


## Installation

Simply download it from [Godot Asset Library](https://godotengine.org/asset-library/asset/275)

Alternatively, download or clone this repository and copy the contents of the
`addons` folder to your own project's `addons` folder.

Important: Enable the plugin on the Project Settings.

## Features

* Import sprite sheets as AtlasTextures

## Usage (once the plugin is enabled)
1. Select the proper pixi.js settings in ShoeBox or Spritesheet Packer then save/publish the spritesheet.
2. Copy the 2 generated files (.png and .js / .json) to your project folder
3. Watch Godot import it automatically.

## License

[MIT License](LICENSE). Copyright (c) 2018 Andreas Loew / CodeAndWeb GmbH
