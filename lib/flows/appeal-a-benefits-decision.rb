satisfies_need "9999"
status :draft
section_slug "money-and-tax"


# TODO: Sanitize date picker values.

# Q1
multiple_choice :already_appealed_the_decision? do
  option :yes => :problem_with_tribunal_proceedure?
  option :no => :date_of_decision_letter?
end

# Q2
multiple_choice :problem_with_tribunal_proceedure? do
  option :missing_doc_or_not_present => :you_can_challenge_decision #A1
  option :mistake_in_law => :can_appeal_to_upper_tribunal #A2
  option :none => :cant_challenge_or_appeal #A3
end

# Q3
date_question :date_of_decision_letter? do
  save_input_as :decision_letter_date
  next_node do |response|
    decision_date = Date.parse(response)
    appeal_expiry_date = decision_date >> 13
    
    if Date.today < appeal_expiry_date
      :had_written_explanation?
    else
      :cant_challenge_or_appeal
    end
  end
end

# Q4
multiple_choice :had_written_explanation? do
  option :spoken_explanation
  option :written_explanation
  option :no
  next_node do |response|
    if response == 'written_explanation'
      :when_did_you_ask_for_it? 
    else
      a_month_has_passed = (Date.parse(decision_letter_date) < Date.today << 1)
      if a_month_has_passed
        :special_circumstances?
      else
        if response == 'spoken_explanation'
          :asked_to_reconsider?
        else
          :ask_for_an_explanation
        end
      end
    end
  end
end

# Q5
date_question :when_did_you_ask_for_it? do
  save_input_as :written_explanation_request_date
  next_node :when_did_you_get_it?
end

# Q6
date_question :when_did_you_get_it? do
  save_input_as :written_explanation_received_date
  next_node do |response|
    
    received_date = Date.parse(response)
    received_within_a_month = received_date > Date.parse(written_explanation_request_date) >> 1
    a_fortnight_has_passed = Date.today > received_date + 14
    a_month_and_a_fortnight_since_decision = Date.today > (Date.parse(decision_letter_date) >> 1) + 14
    
    if (received_within_a_month and a_fortnight_has_passed) or
      (!received_within_a_month and a_month_and_a_fortnight_since_decision)
      :special_circumstances?
    else
      :asked_to_reconsider?
    end
  end
end

# Q7
multiple_choice :special_circumstances? do
  option :yes => :asked_to_reconsider?
  option :no => :cant_appeal
end

# Q8
multiple_choice :asked_to_reconsider? do
  option :yes => :kind_of_benefit_or_credit?
  option :no => :ask_to_reconsider
end

# Q9
multiple_choice :kind_of_benefit_or_credit? do
  option :budgeting_loan => :apply_to_the_independent_review_service
  option :child_maintenance => :appeal_to_the_child_support_agency
  option :housing_benefit => :appeal_to_your_council
  option :tax_credits => :appeal_to_hmrc_wtc
  option :child_benefit => :appeal_to_hmrc_ch24a
  option :other_credit_or_benefit => :appeal_to_social_security
end

outcome :you_can_challenge_decision #A1
outcome :can_appeal_to_upper_tribunal #A2
outcome :cant_challenge_or_appeal #A3
outcome :ask_for_an_explanation #A4
outcome :cant_appeal #A5
outcome :ask_to_reconsider #A6
outcome :apply_to_the_independent_review_service #A7
outcome :appeal_to_the_child_support_agency #A8
outcome :appeal_to_your_council #A9
outcome :appeal_to_hmrc_wtc #A10
outcome :appeal_to_hmrc_ch24a #A11
outcome :appeal_to_social_security #A12
