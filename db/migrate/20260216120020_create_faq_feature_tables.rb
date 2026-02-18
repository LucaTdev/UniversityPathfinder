class CreateFaqFeatureTables < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:faq_votes)
      create_table :faq_votes do |t|
        t.references :faq, null: false, type: :integer, foreign_key: { on_delete: :cascade }
        t.references :user, null: false, foreign_key: { on_delete: :cascade }
        t.integer :value, null: false

        t.timestamps
      end
    end

    add_index :faq_votes, %i[faq_id user_id], unique: true, if_not_exists: true
    add_check_constraint :faq_votes, "\"value\" IN (1, -1)", name: "check_faq_votes_value", if_not_exists: true

    unless table_exists?(:faq_translations)
      create_table :faq_translations do |t|
        t.references :faq, null: false, type: :integer, foreign_key: { on_delete: :cascade }
        t.string :locale, null: false
        t.text :domanda, null: false
        t.text :risposta, null: false

        t.timestamps
      end
    end

    add_index :faq_translations, %i[faq_id locale], unique: true, if_not_exists: true

    unless table_exists?(:faq_suggestions)
      create_table :faq_suggestions do |t|
        t.references :user, null: false, foreign_key: { on_delete: :cascade }
        t.references :faq_category, null: true, foreign_key: { on_delete: :nullify }
        t.text :domanda, null: false
        t.text :dettagli
        t.integer :status, null: false, default: 0

        t.timestamps
      end
    end

    unless table_exists?(:faq_notification_settings)
      create_table :faq_notification_settings do |t|
        t.references :user, null: false, index: false, foreign_key: { on_delete: :cascade }
        t.boolean :enabled, null: false, default: true

        t.timestamps
      end
    end

    if index_exists?(:faq_notification_settings, :user_id, name: "index_faq_notification_settings_on_user_id") &&
        !index_exists?(:faq_notification_settings, :user_id, unique: true, name: "index_faq_notification_settings_on_user_id")
      remove_index :faq_notification_settings, name: "index_faq_notification_settings_on_user_id", if_exists: true
    end

    add_index :faq_notification_settings, :user_id, unique: true, name: "index_faq_notification_settings_on_user_id", if_not_exists: true

    # Notifiche per categoria rimosse: un solo toggle per utente (faq_notification_settings)
  end
end
