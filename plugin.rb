# frozen_string_literal: true

# name: sm-onebox
# about: Onebox support for Strum Machine
# version: 1.0.0
# authors: Luke Abbott
# url: https://github.com/strummachine/sm-onebox

register_asset "stylesheets/sm-onebox.scss"

require_relative 'sm_song_onebox'
require_relative 'sm_list_onebox'

Onebox.options.load_paths.push(File.join(File.dirname(__FILE__), "templates"))