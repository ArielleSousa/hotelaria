require_relative '../../reports/generate_pdf'
require_relative '../../reports/generate_csv'

class Admin::HotelController < ApplicationController

    layout "admin"
    
    def index
        @modulo = "Lista de Hotéis"
        @hoteis = Hotel.all.page params[:page]
    end

    def show
        @hotel = Hotel.find(params[:id])
    end
      
    def destroy
        Hotel.find_by(id: params[:id]).destroy
        redirect_to admin_hotel_index_path
    end

    def new
        @hotel = Hotel.new
    end

    def create
        @hotel = Hotel.new(hotel_params)
        if @hotel.save
            redirect_to admin_hotel_index_path
        else
            render :new
        end
    end 

    def edit
        @hotel = Hotel.find(params[:id])
    end
  
    def update
        @hotel = Hotel.find(params[:id])
  
        if @hotel.update(hotel_params)
            redirect_to admin_hotel_index_path
        else
            render :edit
        end
    end

    def export
        @hotel = Hotel.all

        respond_to do |format|
            format.pdf do
                send_pdf
            end
            format.csv do
                send_csv
            end
        end
    end

    private
        def hotel_params
           params.require(:hotel).permit(:nome, :telefone, :pais, :cidade, :estado, :rua)
        end

        def send_pdf
            colsname = {nome: 'Nome', telefone: 'Telefone', pais:'País', cidade:'Cidade', estado:'Estado', rua:'Rua'}
            widths = [90,90,90,90,90,90]

            relatorio = GeneratePdf.new("Lista de Hoteis", @hotel, colsname, widths)
            pdf = relatorio.pdf
            send_data(pdf, filename: 'relatorio.pdf', type: 'application/pdf', disposition: :inline)
        end

        def send_csv
            colsname = {nome: 'Nome', telefone: 'Telefone', pais:'Pais'}

            relatorio = GenerateCsv.new( @hotel, colsname)
            csv = relatorio.csv
            send_data(csv, filename:'relatorio.csv', type:'text/csv')
        end

           
end
