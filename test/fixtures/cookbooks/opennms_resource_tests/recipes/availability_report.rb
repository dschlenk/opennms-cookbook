# frozen_string_literal: true

opennms_availability_report 'foo' do
  type 'calendar'
  pdf_template 'foo.pdf'
  pdf_template_source 'foo.pdf'

  parameters(
    'string_parms' => [
      {
        'name' => 'category',
        'display_name' => 'Category',
        'input_type' => 'reportCategorySelector',
        'default' => 'Network'
      }
    ],
    'date_parms' => [
      {
        'name' => 'endDate',
        'display_name' => 'End Date',
        'use_absolute_date' => false,
        'default_interval' => 'month',
        'default_count' => 1,
        'default_time' => {
          'hour' => 0,
          'minute' => 0
        }
      }
    ],
    'int_parms' => [
      {
        'name' => 'retryCount',
        'display_name' => 'Retry Count',
        'input_type' => 'freeText',
        'default' => 3
      }
    ]
  )
end

opennms_availability_report 'bar' do
  type 'classic'
  pdf_template 'bar.pdf'
  pdf_template_source 'bar.pdf'

  parameters(
    'string_parms' => [
      {
        'name' => 'category',
        'display_name' => 'Category',
        'input_type' => 'freeText',
        'default' => 'Core'
      }
    ],
    'date_parms' => [
      {
        'name' => 'endDate',
        'display_name' => 'End Date',
        'use_absolute_date' => true,
        'default_interval' => 'day',
        'default_count' => 7,
        'default_time' => {
          'hour' => 6,
          'minute' => 30
        }
      }
    ],
    'int_parms' => [
      {
        'name' => 'retryCount',
        'display_name' => 'Retry Count',
        'input_type' => 'freeText',
        'default' => 5
      }
    ]
  )
end

opennms_availability_report 'baz' do
  type 'calendar'
  pdf_template 'baz.pdf'
  pdf_template_source 'baz.pdf'

  parameters(
    'string_parms' => [
      {
        'name' => 'category',
        'display_name' => 'Category',
        'input_type' => 'reportCategorySelector',
        'default' => 'WAN'
      }
    ],
    'date_parms' => [
      {
        'name' => 'endDate',
        'display_name' => 'End Date',
        'use_absolute_date' => false,
        'default_interval' => 'year',
        'default_count' => 2,
        'default_time' => {
          'hour' => 12,
          'minute' => 15
        }
      }
    ],
    'int_parms' => [
      {
        'name' => 'retryCount',
        'display_name' => 'Retry Count',
        'input_type' => 'freeText',
        'default' => 10
      }
    ]
  )
end

opennms_availability_report 'delete' do
  action :delete
end
