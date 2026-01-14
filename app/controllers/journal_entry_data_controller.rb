# frozen_string_literal: true

class JournalEntryDataController < ApplicationController
  before_action :require_login!

  def index
    @form = JournalEntryDataListForm.new(
      user: current_user,
      payment_month: default_payment_month
    )
    @journal_entries = []
  end

  def display
    @form = build_form_from_params(display_params)
    if @form.valid?(:display)
      generation = JournalEntryData::Generator.call(@form)
      if generation.success?
        @journal_entries = JournalEntryData::Finder.new(current_user: current_user, form: @form).preview_items
        render :index
      else
        flash.now[:alert] = generation.message if generation.message.present?
        @journal_entries = []
        render :index, status: :unprocessable_entity
      end
    else
      @journal_entries = []
      render :index, status: :unprocessable_entity
    end
  end

  def export
    @form = build_form_from_params(export_params)
    if @form.valid?
      generation = JournalEntryData::Generator.call(@form)
      if generation.success?
        result = JournalEntryData::Exporter.call(@form)
        if result.success?
          send_data result.payload[:zip_data],
                    filename: result.payload[:filename],
                    disposition: "attachment",
                    type: "application/zip"
        else
          flash.now[:alert] = result.message || "出力データはありませんでした。"
          @journal_entries = []
          render :index, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = generation.message || "入力内容を確認してください。"
        @journal_entries = []
        render :index, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "入力内容を確認してください。"
      @journal_entries = []
      render :index, status: :unprocessable_entity
    end
  end

  def send_to_bugyo
    @form = build_form_from_params(export_params)
    if @form.valid?
      generation = JournalEntryData::Generator.call(@form)
      if generation.success?
        result = JournalEntryData::Exporter.send_to_bugyo(@form)
        if result.success?
          send_data result.payload[:zip_data],
                    filename: result.payload[:filename],
                    disposition: "attachment",
                    type: "application/zip"
        else
          flash.now[:alert] = result.message || "出力データはありませんでした。"
          @journal_entries = []
          render :index, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = generation.message || "入力内容を確認してください。"
        @journal_entries = []
        render :index, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "入力内容を確認してください。"
      @journal_entries = []
      render :index, status: :unprocessable_entity
    end
  end

  private

  def build_form_from_params(raw_params)
    attrs = raw_params.to_h.symbolize_keys
    attrs[:user] = current_user
    JournalEntryDataListForm.new(attrs)
  end

  def display_params
    params.require(:journal_entry_data_list_form)
          .permit(:payment_month, :supplier, :except_already_output, :fund_transfer_date)
  end

  def export_params
    display_params
  end

  def default_payment_month
    Time.zone.today.strftime("%Y-%m")
  end
end
