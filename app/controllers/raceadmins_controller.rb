class RaceadminsController < ApplicationController
  before_action :set_raceadmin, only: [:show, :edit, :update, :destroy]

  # GET /raceadmins
  # GET /raceadmins.json
  def index
    @raceadmins = Raceadmin.all
  end

  # GET /raceadmins/1
  # GET /raceadmins/1.json
  def show
  end

  # GET /raceadmins/new
  def new
    @raceadmin = Raceadmin.new
  end

  # GET /raceadmins/1/edit
  def edit
  end

  # POST /raceadmins
  # POST /raceadmins.json
  def create
    @raceadmin = Raceadmin.new(raceadmin_params)

    respond_to do |format|
      if @raceadmin.save
        format.html { redirect_to @raceadmin, notice: 'Raceadmin was successfully created.' }
        format.json { render :show, status: :created, location: @raceadmin }
      else
        format.html { render :new }
        format.json { render json: @raceadmin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /raceadmins/1
  # PATCH/PUT /raceadmins/1.json
  def update
    respond_to do |format|
      if @raceadmin.update(raceadmin_params)
        format.html { redirect_to @raceadmin, notice: 'Raceadmin was successfully updated.' }
        format.json { render :show, status: :ok, location: @raceadmin }
      else
        format.html { render :edit }
        format.json { render json: @raceadmin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /raceadmins/1
  # DELETE /raceadmins/1.json
  def destroy
    @raceadmin.destroy
    respond_to do |format|
      format.html { redirect_to raceadmins_url, notice: 'Raceadmin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_raceadmin
      @raceadmin = Raceadmin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def raceadmin_params
      params.require(:raceadmin).permit(:year, :user_id)
    end
end
