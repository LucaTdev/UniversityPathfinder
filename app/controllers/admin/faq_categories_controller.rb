module Admin
  class FaqCategoriesController < ApplicationController
    before_action :require_login
    before_action :authorize_admin!
    before_action :set_category, only: %i[update destroy]

    def index
      render json: { categories: categories_payload }
    end

    def create
      category = FaqCategory.new(category_params)

      if category.save
        render json: { categories: categories_payload }, status: :created
      else
        render json: { error: "invalid", messages: category.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @category.general?
        return render json: { error: "forbidden", messages: ["Non puoi rinominare la categoria predefinita."] },
          status: :forbidden
      end

      if @category.update(category_params)
        render json: { categories: categories_payload }
      else
        render json: { error: "invalid", messages: @category.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      if @category.destroy
        render json: { categories: categories_payload }
      else
        render json: { error: "invalid", messages: @category.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_category
      @category = FaqCategory.find(params[:id])
    end

    def category_params
      params.require(:faq_category).permit(:name)
    end

    def categories_payload
      ordered = FaqCategory
        .order(Arel.sql("CASE WHEN lower(name) = '#{FaqCategory::GENERAL_NAME.downcase}' THEN 0 ELSE 1 END"))
        .order(Arel.sql("lower(name)"))

      counts = Faq.group(:faq_category_id).count

      ordered.map do |c|
        {
          id: c.id,
          name: c.name,
          faqs_count: counts[c.id] || 0,
          general: c.general?
        }
      end
    end
  end
end

