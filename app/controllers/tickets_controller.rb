class TicketsController < ApplicationController
  layout false
  before_filter :set_event

  def new
    @ticket = @event.tickets.new(ticket_params)
    authorize(@ticket)
  end

  def create
    @ticket = @event.tickets.new(ticket_params)
    authorize(@ticket)
    if @ticket.save
      flash[:info] = 'Ticket successfully added.'
    else
      flash[:error] = 'Something went wrong. Please try again.'
    end
    redirect_to edit_event_path(@event, page: 'tickets')
  end

  def edit
    @ticket = @event.tickets.find(params[:id])
    authorize(@ticket)
  end

  def update
    @ticket = @event.tickets.find(params[:id])
    authorize(@ticket)
    if @ticket.update_attributes(ticket_params)
      flash[:info] = "Ticket has been successfully updated."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to edit_event_path(@event, page: 'tickets')
  end

  def destroy
    @ticket = @event.tickets.find(params[:id])
    authorize(@ticket)
    if @ticket.destroy
      flash[:info] = "Ticket has been successfully removed."
    else
      flash[:error] = "Somthing went wrong. Please try again."
    end
    redirect_to :back
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def ticket_params
    permitted_params(:ticket).tap do |t|
      t[:cost].delete!('$') if t[:cost]
    end
  end

end
