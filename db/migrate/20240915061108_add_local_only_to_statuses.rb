# frozen_string_literal: true

class AddLocalOnlyToStatuses < ActiveRecord::Migration[7.0]
  def up
    add_column :statuses, :local_only, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
    change_column_default :statuses, :local_only, false
  end

  def down
    remove_column :statuses, :local_only
  end
end
