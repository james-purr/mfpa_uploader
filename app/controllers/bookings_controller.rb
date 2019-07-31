class BookingsController < ApplicationController

  def show
    @booking = Booking.find(params[:id])
    @next_booking = Booking.where(complete:false).where('id > ?', @booking.id).first
    @last_booking = Booking.where(complete:false).last
    @previous_booking = Booking.where(complete:false).where('id < ?', @booking.id).last
  end

  def reference
    @reference = params[:reference]
    render "show"
  end
end
