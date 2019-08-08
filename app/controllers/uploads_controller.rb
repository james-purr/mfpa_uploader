class UploadsController < ApplicationController
  before_action :set_upload, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, except: [:search, :get_missing_images]
  # GET /uploads
  # GET /uploads.json
  def index
    @booking = Booking.where(complete:false).first
    @next_booking = Booking.where(complete:false).where('id > ?', @booking.id).first
    @last_booking = Booking.where(complete:false).last
  end

  def search_bookings
    @booking = Booking.where(complete:false).first
    @next_booking = Booking.where(complete:false).where('id > ?', @booking.id).first
    @last_booking = Booking.where(complete:false).last
  end

  # GET /uploads/1
  # GET /uploads/1.json
  def show
  end

  # GET /uploads/new
  def new
    @upload = Upload.new
  end

  # GET /uploads/1/edit
  def edit
  end

  def search
    require 'net/http'
    uri = URI('https://secure.shipfromuk.com/api_search')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    new_params = params.except(:controller, :action, :utf8, :authenticity_token, :commit)
    new_params = new_params.reject{|_, v| v.blank?}
    params_to_pass = {}
    new_params.each{|p| params_to_pass[p] = new_params[p]}
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = params_to_pass.to_json
    response = http.request(request)
    respond_to do |format|
      format.json { render json: JSON.parse(response.body) , status: :ok}
    end
    # @bookings =
  end

  def get_missing_images
    require 'net/http'
    id = params[:id]
    uri = URI.parse("https://secure.shipfromuk.com/missing_images/#{id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.get(uri.request_uri)
    parsed = JSON.parse(response.body)
    names =  parsed["pictures"].map{|picture| picture["picture"]["name"]}.uniq
    singled_pics = []
    names.each do |name|
      singled_pics.push(parsed["pictures"].select{|image| image["picture"]["name"] == name}.last)
    end

    return_object = {}
    checkin = singled_pics.select{|pic| pic["picture"]["name"].include?("checkin")}
    rtl = singled_pics.select{|pic| pic["picture"]["name"].include?("rtl")}
    loaded = singled_pics.select{|pic| pic["picture"]["name"].include?("loaded")}
    inspection = singled_pics - loaded - checkin - rtl
    return_object['singled_pics'] = {}
    return_object['singled_pics']["inspection"] = inspection
    return_object['singled_pics']["checkin"] = checkin
    return_object['singled_pics']["rtl"] = rtl
    return_object['singled_pics']["loaded"] = loaded
    ['inspection', 'rtl', 'loaded'].each do |section|
      if !return_object['singled_pics'][section].select{|pic| pic["exists"] == false}.any?
         booking = Booking.find_by(booking_id: id)
         booking[stage_translator(section)] = true
         booking.save!

      end
    end
    return_object['booking'] = parsed["booking"]
    respond_to do |format|
      format.json { render json: return_object , status: :ok}
    end
  end

  # POST /uploads
  # POST /uploads.json
  def create
    @upload = Upload.new(upload_params)

    respond_to do |format|
      if @upload.save
        format.html { redirect_to @upload, notice: 'Upload was successfully created.' }
        format.json { render :show, status: :created, location: @upload }
      else
        format.html { render :new }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_to_server
    file = params[:file]
    uploader = ImageUploader.new
    uploader.store!(file)
    # get remote file path of image
    match_file_path_large = params["large"].split('/').last
    match_file_path_thumb = params["thumb"].split('/').last

    # get local foler path of 2 images
    large_folder_path = Rails.root.to_s + "/public" + (uploader.url.split('/') - [uploader.url.split('/').last]).join('/')
    thumb_folder_path = Rails.root.to_s + "/public" + (uploader.url(:thumb).split('/') - [uploader.url(:thumb).split('/').last]).join('/')

    File.rename( Rails.root.to_s + "/public" + uploader.url, large_folder_path + "/" + match_file_path_large)
    File.rename( Rails.root.to_s + "/public" + uploader.url(:thumb), thumb_folder_path + "/" + match_file_path_thumb)

    large_upload_file_path = large_folder_path + "/" + match_file_path_large
    thumb_upload_file_path = thumb_folder_path + "/" + match_file_path_thumb
    existing_file_path_large = "/srv/apps/production/public" + params["large"]
    existing_file_path_original = "/srv/apps/production/public" + params["original"]
    existing_file_path_thumb = "/srv/apps/production/public" + params["thumb"]
    # existing_file_path = (existing_file_path.split('/') - [existing_file_path.split('/').last]).join('/')
    response = false
    Net::SFTP.start('sfuk01.default.uglogvirtual.uk0.bigv.io', 'admin', :password => '6XPfdi9Son') do |sftp|
      sftp.upload!(thumb_upload_file_path, existing_file_path_thumb)
      sftp.upload!(large_upload_file_path, existing_file_path_original)
      sftp.upload!(large_upload_file_path, existing_file_path_large)
    end
  end

  # PATCH/PUT /uploads/1
  # PATCH/PUT /uploads/1.json
  def update
    respond_to do |format|
      if @upload.update(upload_params)
        format.html { redirect_to @upload, notice: 'Upload was successfully updated.' }
        format.json { render :show, status: :ok, location: @upload }
      else
        format.html { render :edit }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uploads/1
  # DELETE /uploads/1.json
  def destroy
    @upload.destroy
    respond_to do |format|
      format.html { redirect_to uploads_url, notice: 'Upload was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_upload
      @upload = Upload.find(params[:id])
    end

    def stage_translator (field)
      return 'inspection_complete' if field == 'inspection'
      return 'ready_to_load_complete' if field == 'rtl'
      return 'loaded_complete' if field == 'loaded'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def upload_params
      params.require(:upload).permit(:booking_id, :original_file_name)
    end
end
