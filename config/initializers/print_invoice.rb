Spree::PrintInvoice::Config.set(print_invoice_logo_path: "/home/likewise-open/CHETU/shaktik/bhanu/my_store/app/assets/images/logo.png")
Spree::PrintInvoice::Config.set(:print_buttons => "invoice")
Spree::PrintInvoice::Config.set(:prawn_options => {:page_layout => :landscape, :page_size => "A4", :margin => [50, 100, 150, 200]})