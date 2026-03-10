class DropFaqNotificationSubscriptions < ActiveRecord::Migration[8.0]
  def change
    drop_table :faq_notification_subscriptions, if_exists: true
  end
end

