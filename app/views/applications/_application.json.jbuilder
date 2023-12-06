# frozen_string_literal: true
json.extract! application, :id, :application_type_id, :reference_number, :converted_to_from, :council_id, :development_application_number, :applicant_id, :owner_id, :contact_id, :description, :cancelled, :street_number, :lot_number, :street_name, :suburb_id, :electronic_lodgement, :engagement_form, :job_type_administration, :quote_accepted_date, :administration_notes, :number_of_storeys, :construction_value, :fee_amount, :building_surveyor, :structural_engineer, :external_engineer_date, :risk_rating, :consultancies_review_inspection, :consultancies_report_sent, :assessment_commenced, :request_for_information_issued, :consent_issued, :variation_issued, :staged, :coo_issued, :engineer_certificate_received, :certification_notes, :invoice_to, :care_of, :invoice_email, :attention, :purchase_order_number, :fully_invoiced, :invoice_debtor_notes, :applicant_email, :sort_priority_gen, :created_at, :updated_at
json.url application_url(application, format: :json)
