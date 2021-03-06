#  Copyright (c) 2013-2014 SUSE LLC
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 3 of the GNU General Public License as
#  published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.
#
#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com
require 'trello'

class TrelloWrapper

  attr_accessor :board

  def initialize(settings)
    @settings = settings
    init_trello
  end

  def client
    Trello::Client.new(
      developer_public_key: @settings.developer_public_key,
      member_token: @settings.member_token
    )
  end

  def board(board_id)
    return @board if @board

    @board = ScrumBoard.new(retrieve_board_data(board_id), @settings)
  end

  def retrieve_board_data(board_id)
    JSON.parse(client.get("/boards/#{board_id}?lists=open&cards=open&card_checklists=all"))
  end

  def backup(board_id)
    client.get("/boards/#{board_id}?lists=open&cards=open&card_checklists=all")
  end

  def organization(org_id)
    Trello::Organization.find(org_id)
  end

  private

  def init_trello
    Trello.configure do |config|
      config.developer_public_key = @settings.developer_public_key
      config.member_token         = @settings.member_token
    end
  end

end
