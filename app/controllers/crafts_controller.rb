class CraftsController < ApplicationController
  before_action :set_craft, only: [:show, :edit, :update, :destroy]

  # GET /crafts
  # GET /crafts.json
  def index
    @crafts = Craft.all
  end

  # GET /crafts/1
  # GET /crafts/1.json
  def show
  end

  # GET /crafts/new
  def new
    @craft = Craft.new
  end

  # GET /crafts/1/edit
  def edit
  end

  # POST /crafts
  # POST /crafts.json
  def create
    @craft = Craft.new(craft_params)

    respond_to do |format|
      if @craft.save
        format.html { redirect_to @craft, notice: 'Craft was successfully created.' }
        format.json { render :show, status: :created, location: @craft }
      else
        format.html { render :new }
        format.json { render json: @craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /crafts/1
  # PATCH/PUT /crafts/1.json
  def update
    respond_to do |format|
      if @craft.update(craft_params)
        format.html { redirect_to @craft, notice: 'Craft was successfully updated.' }
        format.json { render :show, status: :ok, location: @craft }
      else
        format.html { render :edit }
        format.json { render json: @craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crafts/1
  # DELETE /crafts/1.json
  def destroy
    @craft.destroy
    respond_to do |format|
      format.html { redirect_to crafts_url, notice: 'Craft was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def location
    format = 'osm'
    canoe = 'all'
    precision = 4
    
    @title = if canoe.casecmp('all').zero?
               'All Canoe Locations'
             else
               "Canoe #{ canoe }"
             end
    
    @list = Location.uniq_location(precision, canoe, true)
    sum_longitude = 0.0
    sum_latitude = 0.0

    count = 0
    @list.each do |number, hash|
      count += 1
      sum_longitude += hash[:longitude].to_f
      sum_latitude += hash[:latitude].to_f
    end

    if sum_longitude == 0.0
      @map_longitude = '-33.505'
    else
      @map_longitude = (sum_longitude / count).round(precision).to_s
    end

    if sum_latitude == 0.0
      @map_latitude = '151.15'
    else
      @map_latitude = (sum_latitude / count).round(precision).to_s
    end

    render 'location', :layout => false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_craft
      @craft = Craft.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def craft_params
      params.require(:craft).permit(:number, :year, :status, :time, :entered, :user_id)
    end
end
