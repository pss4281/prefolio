class TemplatesController < ApplicationController

  def new
    @template = ImageTemplate.new
  end

  def jcrop
    @template = ImageTemplate.find(params[:id])
  end

  def create
    @template = ImageTemplate.new(create_params)
    if @template.save
      redirect_to edit_template_path(@template)
    else
      render :new
    end
  end

  def edit
    @template = ImageTemplate.find params[:id]
    render 'edit_step3' and return if params[:step] == "3"
    render 'edit_step2'
  end

  def update
    @template = ImageTemplate.find(params[:id])
    @template.assign_attributes(update_params)
    @template.image.recreate_versions!
    if @template.save
      if params[:commit] == "move-to-step-3"
        redirect_to edit_template_path(@template, step: '3'), notice: "Saved"
      elsif params[:commit] == "template-complete"
        redirect_to template_path(@template)
      else
        redirect_to edit_template_path(@template), notice: "Saved"
      end
    else
      render :edit
    end
  end

  def show
    @template = ImageTemplate.find(params[:id])
  end

  def index
    @templates = ImageTemplate.all
    @col1_items = []
    @col2_items = []
    @col3_items = []
    @templates.each_with_index do |tpl, i|
      @col1_items << tpl if i % 3 == 0
      @col2_items << tpl if i % 3 == 1
      @col3_items << tpl if i % 3 == 2
    end
  end

  private

  def create_params
    params.require(:image_template).permit(:image)
  end

  def update_params
    params.require(:image_template).permit(embed_rules_attributes: [
      :id, :composite_position_x, :composite_position_y,
      :destination_size_x, :destination_size_y, destination_points: []
    ])
  end
end
