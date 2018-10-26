class LoraDeviceMappingsController < ApplicationController
  before_action :set_lora_device_mapping, only: [:show, :edit, :update, :destroy]

  # GET /lora_device_mappings
  # GET /lora_device_mappings.json
  def index
    @lora_device_mappings = LoraDeviceMapping.all
  end

  # GET /lora_device_mappings/1
  # GET /lora_device_mappings/1.json
  def show
  end

  # GET /lora_device_mappings/new
  def new
    @lora_device_mapping = LoraDeviceMapping.new
  end

  # GET /lora_device_mappings/1/edit
  def edit
  end

  # POST /lora_device_mappings
  # POST /lora_device_mappings.json
  def create
    @lora_device_mapping = LoraDeviceMapping.new(lora_device_mapping_params)

    respond_to do |format|
      if @lora_device_mapping.save
        format.html { redirect_to @lora_device_mapping, notice: 'Lora device mapping was successfully created.' }
        format.json { render :show, status: :created, location: @lora_device_mapping }
      else
        format.html { render :new }
        format.json { render json: @lora_device_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lora_device_mappings/1
  # PATCH/PUT /lora_device_mappings/1.json
  def update
    respond_to do |format|
      if @lora_device_mapping.update(lora_device_mapping_params)
        format.html { redirect_to @lora_device_mapping, notice: 'Lora device mapping was successfully updated.' }
        format.json { render :show, status: :ok, location: @lora_device_mapping }
      else
        format.html { render :edit }
        format.json { render json: @lora_device_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lora_device_mappings/1
  # DELETE /lora_device_mappings/1.json
  def destroy
    @lora_device_mapping.destroy
    respond_to do |format|
      format.html { redirect_to lora_device_mappings_url, notice: 'Lora device mapping was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lora_device_mapping
      @lora_device_mapping = LoraDeviceMapping.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lora_device_mapping_params
      params.require(:lora_device_mapping).permit(:device_registration, :number)
    end
end
