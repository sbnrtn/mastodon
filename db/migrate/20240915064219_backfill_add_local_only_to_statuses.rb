# frozen_string_literal: true

class BackfillAddLocalOnlyToStatuses < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    Status.unscoped.in_batches do |relation|
      relation.update_all local_only: false # rubocop:disable Rails/SkipsModelValidations
      sleep(0.01)
    end

    Status.unscoped.limitedprofile_visibility.in_batches do |relation|
      relation.update_all local_only: true # rubocop:disable Rails/SkipsModelValidations
      sleep(0.01)
    end
  end
end
