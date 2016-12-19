define_grid(columns: 5, rows: 8, gutter: 10)



# CONTENT
grid([1,0], [6,4]).bounding_box do

  font @font_face, size: @font_size

  # address block on first page only
  repeat(lambda { |pg| pg == 1 }) do
    bill_address = @order.bill_address
    ship_address = @order.ship_address

    move_down 2
    address_cell_billing  = make_cell(content: Spree.t(:billing_address), font_style: :bold)
    address_cell_shipping = make_cell(content: Spree.t(:shipping_address), font_style: :bold)

    billing =  "#{bill_address.firstname} #{bill_address.lastname}"
    billing << "\n#{bill_address.address1}"
    billing << "\n#{bill_address.address2}" unless bill_address.address2.blank?
    billing << "\n#{bill_address.city}, #{bill_address.state_text} #{bill_address.zipcode}"
    billing << "\n#{bill_address.country.name}"
    billing << "\n#{bill_address.phone}"

    shipping =  "#{ship_address.firstname} #{ship_address.lastname}"
    shipping << "\n#{ship_address.address1}"
    shipping << "\n#{ship_address.address2}" unless ship_address.address2.blank?
    shipping << "\n#{ship_address.city}, #{ship_address.state_text} #{ship_address.zipcode}"
    shipping << "\n#{ship_address.country.name}"
    shipping << "\n#{ship_address.phone}"
    shipping << "\n\n#{Spree.t(:via, scope: :print_invoice)} #{@order.shipments.first.shipping_method.name}"

    data = [[address_cell_billing, address_cell_shipping], [billing, shipping]]
    table(data, position: :center, column_widths: [270, 270])
  end

  move_down 10

  header = [
    make_cell(content: Spree.t(:sku)),
    make_cell(content: Spree.t(:item_description)),
    make_cell(content: Spree.t(:options)),
    make_cell(content: Spree.t(:price)),
    make_cell(content: Spree.t(:qty)),
    make_cell(content: Spree.t(:total))
  ]
  data = [header]

  @order.line_items.each do |item|
    row = [
      item.variant.sku,
      item.variant.name,
      item.variant.options_text,
      item.single_display_amount.to_s,
      item.quantity,
      item.display_total.to_s
    ]
    data += [row]
  end

  table(data, header: true, position: :center, column_widths: [70, 200, 100, 65, 40, 65]) do
    row(0).style align: :center, font_style: :bold
    column(0..2).style align: :left
    column(3..6).style align: :right
  end

  # TOTALS
  move_down 10
  totals = []

  # Subtotal
  totals << [make_cell(content: Spree.t(:subtotal)), @order.display_item_total.to_s]

  # Adjustments
  @order.all_adjustments.eligible.each do |adjustment|
    totals << [make_cell(content: adjustment.label), adjustment.display_amount.to_s]
  end

  # Shipments
  @order.shipments.each do |shipment|
    totals << [make_cell(content: shipment.shipping_method.name), shipment.display_cost.to_s]
  end

  # Totals
  totals << [make_cell(content: Spree.t(:order_total)), @order.display_total.to_s]

  # Payments
  total_payments = 0.0
  @order.payments.each do |payment|
    totals << [
      make_cell(
        content: Spree.t(:payment_via,
        gateway: (payment.source_type || Spree.t(:unprocessed, scope: :print_invoice)),
        date: I18n.l(payment.updated_at.to_date, format: :long),
        scope: :print_invoice)
      ),
      payment.display_amount.to_s
    ]
    total_payments += payment.amount
  end

  table(totals, column_widths: [475, 65]) do
    row(0..6).style align: :right
    column(0).style borders: [], font_style: :bold
  end

  move_down 30
end
