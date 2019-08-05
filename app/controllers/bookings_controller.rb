class BookingsController < ApplicationController

  def show
    @booking = Booking.find(params[:id])
    @next_booking = Booking.where(complete:false).where('id > ?', @booking.id).first
    @last_booking = Booking.where(complete:false).last
    @previous_booking = Booking.where(complete:false).where('id < ?', @booking.id).last
  end

  def update_booking_status
    booking = Booking.find_by(booking_id: params["id"])
    booking[stage_translator(params[:status])] = true
    booking.save!
  end

  def reference
    @reference = params[:reference]
    render "show"
  end

  private

  def stage_translator (status)
    return 'inspection_complete' if status == 'inspection'
    return 'ready_to_load_complete' if status == 'rtl'
    return 'loaded_complete' if status == 'loaded'
  end
end
