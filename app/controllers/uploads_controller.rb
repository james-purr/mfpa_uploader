class UploadsController < ApplicationController
  before_action :set_upload, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, except: [:search, :get_missing_images]
  # GET /uploads
  # GET /uploads.json
  def index
    @uploads = Upload.all
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
    names = parsed.map{|picture| picture["name"]}.uniq
    singled_pics = []
    names.each do |name|
      singled_pics.push(parsed.select{|image| image["name"] == name}.last)
    end
    respond_to do |format|
      format.json { render json: singled_pics , status: :ok}
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
    match_file_path = params["large"].split('/').last
    folder_path = Rails.root.to_s + "/public" + (uploader.url.split('/') - [uploader.url.split('/').last]).join('/')
    File.rename( Rails.root.to_s + "/public" + uploader.url, folder_path + "/" + match_file_path)
    upload_file_path = folder_path + "/" + match_file_path
    existing_file_path = params["large"]
    existing_file_path = (existing_file_path.split('/') - [existing_file_path.split('/').last]).join('/')
    Net::SCP.start("sfuk01.default.uglogvirtual.uk0.bigv.io", "admin", :password => "6XPfdi9Son") do |scp|

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

    # Never trust parameters from the scary internet, only allow the white list through.
    def upload_params
      params.require(:upload).permit(:booking_id, :original_file_name)
    end
end
