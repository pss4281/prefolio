class ProcessedImagesController < ApplicationController
  protect_from_forgery except: :create 

  def create
    @template = ImageTemplate.find(params[:template_id])
    @processed_image = @template.processed_images.build(prev_image_id: params[:processed_image_id])
    @processed_image.embed_rule = @template.embed_rules.find(params[:rule_id])
    @processed_image.assign_attributes( image: params[:file] )

    if @processed_image.save
      render json: @processed_image.to_json
    else
      render json: { errors: @processed_image.errors.full_messages.join(' ') }, status: :unprocessable_entity
    end
  end

  def update
    @template = ImageTemplate.find(params[:template_id])
    @processed_image = @template.processed_images.find(params[:id])
    @processed_image.embed_rule = @template.embed_rules.find(params[:rule_id])
    @processed_image.assign_attributes( image: params[:file] )
    if @processed_image.save
      render json: @processed_image.to_json
    else
      render json: { errors: @processed_image.errors.full_messages.join(' ') }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.require(:processed_image).permit(:image)
  end

end
