require "spec_helper"

RSpec.describe Facility do
  before(:each) do
    @facility_1 = Facility.new({name: "Albany DMV Office", address: "2242 Santiam Hwy SE Albany OR 97321", phone: "541-967-2014" })
    @facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })

    @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice} )
    @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )
    @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice} )
  end

  describe "#initialize" do
    it "can initialize" do
      expect(@facility_1).to be_an_instance_of(Facility)
      expect(@facility_1.name).to eq("Albany DMV Office")
      expect(@facility_1.address).to eq("2242 Santiam Hwy SE Albany OR 97321")
      expect(@facility_1.phone).to eq("541-967-2014")
      expect(@facility_1.services).to eq([])
      expect(@facility_1.registered_vehicles).to eq([])
      expect(@facility_1.collected_fees).to eq(0)
    end
  end

  describe "#add_service" do
    it "can add available services" do
      expect(@facility_1.services).to eq([])
      @facility_1.add_service("New Drivers License")
      @facility_1.add_service("Renew Drivers License")
      @facility_1.add_service("Vehicle Registration")
      expect(@facility_1.services).to eq(["New Drivers License", "Renew Drivers License", "Vehicle Registration"])
    end
  end

  describe "#register_vehicle" do
    it "can register a Vehicle if it offers Vehicle Registration service" do
      @facility_1.add_service("Vehicle Registration")      
      @facility_1.register_vehicle(@cruz)

      expect(@facility_1.registered_vehicles).to eq([@cruz])
    end
    
    it "cannot register a Vehicle if it does not offer Vehicle Registration service" do      
      @facility_1.register_vehicle(@cruz)
      expect(@facility_1.registered_vehicles).to eq([])
    end
    
    it "can only register Vehicle objects" do
      @facility_1.add_service("Vehicle Registration")
      
      registrant = Registrant.new("Ethan", 28)
      
      @facility_1.register_vehicle(registrant)
      expect(@facility_1.registered_vehicles).to eq([])
    end
    
    it "can assign a registration_date to a Vehicle" do
      @facility_1.add_service("Vehicle Registration")
      
      expect(@cruz.registration_date).to be nil
      
      @facility_1.register_vehicle(@cruz)
      expect(@cruz.registration_date).to be_a(Date)
    end
    
    it "can assign a plate_type to a Vehicle" do
      @facility_1.add_service("Vehicle Registration")
      
      expect(@cruz.plate_type).to be nil
      
      @facility_1.register_vehicle(@cruz)
      expect(@cruz.plate_type).to eq(:regular)
    end
    
    it "can collect $25 to register an :antique Vehicle" do
      @facility_1.add_service("Vehicle Registration")

      expect(@facility_1.collected_fees).to eq(0)

      @facility_1.register_vehicle(@camaro)

      expect(@facility_1.collected_fees).to eq(25)
    end

    it "can collect a $200 fee to register an :ev Vehicle" do
      @facility_1.add_service("Vehicle Registration")

      expect(@facility_1.collected_fees).to eq(0)

      @facility_1.register_vehicle(@bolt)

      expect(@facility_1.collected_fees).to eq(200)
    end

    it "can collect a $100 fee to register all other Vehicles that are not :ev or :antique" do
      @facility_1.add_service("Vehicle Registration")

      expect(@facility_1.collected_fees).to eq(0)

      @facility_1.register_vehicle(@cruz)

      expect(@facility_1.collected_fees).to eq(100)
    end
    
    it "can collect registration fees from all kinds of Vehicles" do
      @facility_1.add_service("Vehicle Registration")

      @facility_1.register_vehicle(@cruz)
      expect(@facility_1.collected_fees).to eq(100)
      
      @facility_1.register_vehicle(@camaro)
      expect(@facility_1.collected_fees).to eq(125)
      
      @facility_1.register_vehicle(@bolt)
      expect(@facility_1.collected_fees).to eq(325)
    end
  end
  
  describe "#collect_fee" do
    it "can collect a $25 fee from an :antique Vehicle" do
      expect(@facility_1.collected_fees).to eq(0)
      
      @facility_1.collect_fee(@camaro)
      
      expect(@facility_1.collected_fees).to eq(25)
    end
    
    it "can collect a $200 fee from an :ev Vehicle" do
      expect(@facility_1.collected_fees).to eq(0)
      
      @facility_1.collect_fee(@bolt)
      
      expect(@facility_1.collected_fees).to eq(200)
    end
    
    it "can collect a $100 fee from all other Vehicles that are not :ev or :antique" do
      expect(@facility_1.collected_fees).to eq(0)
      
      @facility_1.collect_fee(@cruz)
      
      expect(@facility_1.collected_fees).to eq(100)
    end
    
    it "can collect fees from all kinds of Vehicles" do
      expect(@facility_1.collected_fees).to eq(0)
      
      @facility_1.collect_fee(@camaro)
      @facility_1.collect_fee(@bolt)
      @facility_1.collect_fee(@cruz)
      expect(@facility_1.collected_fees).to eq(325)
    end
  end

  describe "#administer_written_test" do
    before(:each) do
      @registrant_1 = Registrant.new("Bruce", 18, true)
      @registrant_2 = Registrant.new("Penny", 16)
      @registrant_3 = Registrant.new("Tucker", 15)
    end

    it "can administer a written test if it offers Written Test service" do
      expect(@facility_1.services).to eq([])
      expect(@registrant_1.license_data[:written]).to be false
      
      @facility_1.add_service("Written Test")
      @facility_1.administer_written_test(@registrant_1)
      
      # expect(@registrant_1.license_data[:written]).to be true
      expect(@facility_1.administer_written_test(@registrant_1)).to be true
      expect(@facility_1.services).to eq(["Written Test"])
    end
    
    it "cannot administer a written test if does not offer Written Test service" do
      expect(@facility_1.services).to eq([])
      expect(@registrant_1.license_data[:written]).to be false
      
      @facility_1.administer_written_test(@registrant_1)
      
      expect(@facility_1.administer_written_test(@registrant_1)).to be false
      expect(@registrant_1.license_data[:written]).to be false
    end
    
    it "can only administer written tests to Registrants with permits and who are at least 16 years old" do
      @facility_1.add_service("Written Test")
      
      expect(@registrant_1.permit?).to be true
      expect(@registrant_1.age >= 16).to be true
      expect(@registrant_2.permit?).to be false
      expect(@registrant_2.age >= 16).to be true
      expect(@registrant_3.permit?).to be false
      expect(@registrant_3.age >= 16).to be false

      expect(@facility_1.administer_written_test(@registrant_1)).to be true
      expect(@facility_1.administer_written_test(@registrant_2)).to be false
      expect(@facility_1.administer_written_test(@registrant_3)).to be false

      expect(@registrant_1.license_data[:written]).to be true
      expect(@registrant_2.license_data[:written]).to be false
      expect(@registrant_3.license_data[:written]).to be false

      @registrant_2.earn_permit
      @registrant_3.earn_permit
      
      expect(@registrant_2.permit?).to be true
      expect(@registrant_3.permit?).to be true

      @facility_1.administer_written_test(@registrant_2)
      @facility_1.administer_written_test(@registrant_3)

      expect(@registrant_2.license_data[:written]).to be true
      expect(@registrant_3.license_data[:written]).to be false
    end

    it "can only administer written tests to Registrant objects" do
      @facility_1.add_service("Written Test")

      expect(@facility_1.administer_written_test(@cruz)).to be false
      expect(@facility_1.administer_written_test(@registrant_1)).to be true
    end
  end
  
  describe "#administer_road_test" do
    before(:each) do
      @facility_1.add_service("Written Test")

      @registrant_1 = Registrant.new("Bruce", 18, true)
      @facility_1.administer_written_test(@registrant_1)
      
      @registrant_2 = Registrant.new("Penny", 16)
      @facility_1.administer_written_test(@registrant_2)

      @registrant_3 = Registrant.new("Tucker", 15)
      @facility_1.administer_written_test(@registrant_3)
    end

    it "can administer a road test if it offers Road Test service" do
      @facility_1.add_service("Road Test")

      expect(@facility_1.services).to eq(["Written Test", "Road Test"])
      expect(@facility_1.administer_road_test(@registrant_1)).to be true
    end
    
    it "cannot administer a road test if it does not offer Road Test service" do      
      expect(@facility_1.services).to eq(["Written Test"])
      expect(@facility_1.administer_road_test(@registrant_1)).to be false
    end
    
    it "can only administer a road test to Registrants who passed their written test" do
      @facility_1.add_service("Road Test")
      
      expect(@registrant_1.license_data[:written]).to be true
      expect(@registrant_2.license_data[:written]).to be false
      
      expect(@facility_1.administer_road_test(@registrant_1)).to be true
      expect(@facility_1.administer_road_test(@registrant_2)).to be false
    end
    
    it "can give registrants who pass the road test a license" do
      @facility_1.add_service("Road Test")
      
      expect(@registrant_1.license_data[:license]).to be false
      expect(@registrant_2.license_data[:license]).to be false
      
      @facility_1.administer_road_test(@registrant_1)
      @facility_1.administer_road_test(@registrant_2)

      expect(@registrant_1.license_data[:license]).to be true
      expect(@registrant_2.license_data[:license]).to be false
    end 

    it "can only administer road tests to Registrant objects" do
      @facility_1.add_service("Road Test")

      expect(@facility_1.administer_road_test(@cruz)).to be false
      expect(@facility_1.administer_road_test(@registrant_1)).to be true
    end
  end

  describe "#renew_drivers_license" do
    before(:each) do
      @facility_1.add_service("Written Test")
      @facility_1.add_service("Road Test")

      @registrant_1 = Registrant.new("Bruce", 18, true)
      @facility_1.administer_written_test(@registrant_1)
      @facility_1.administer_road_test(@registrant_1)
      
      @registrant_2 = Registrant.new("Penny", 16)
      @facility_1.administer_written_test(@registrant_2)
      @facility_1.administer_road_test(@registrant_2)

      @registrant_3 = Registrant.new("Tucker", 15)
      @facility_1.administer_written_test(@registrant_3)
      @facility_1.administer_road_test(@registrant_3)
    end

    it "can renew a license if it offers Renew License service" do
      expect(@facility_1.services).to eq(["Written Test", "Road Test"])

      @facility_1.add_service("Renew License")
      
      expect(@facility_1.services).to eq(["Written Test", "Road Test", "Renew License"])
      expect(@facility_1.renew_drivers_license(@registrant_1)).to be true
    end
    
    it "cannot renew a license if it does not offer Renew License service" do
      expect(@facility_1.services).to eq(["Written Test", "Road Test"])
      expect(@facility_1.renew_drivers_license(@registrant_1)).to be false
    end
    
    it "can only renew a license for Registrants who passed their road test and earned a license" do
      @facility_1.add_service("Renew License")

      expect(@registrant_1.license_data[:license]).to be true
      expect(@registrant_2.license_data[:license]).to be false
      expect(@registrant_1.license_data[:renewed]).to be false
      expect(@registrant_2.license_data[:renewed]).to be false
      
      expect(@facility_1.renew_drivers_license(@registrant_1)).to be true
      expect(@facility_1.renew_drivers_license(@registrant_2)).to be false
      
      @facility_1.renew_drivers_license(@registrant_1)
      @facility_1.renew_drivers_license(@registrant_2)

      expect(@registrant_1.license_data[:renewed]).to be true
      expect(@registrant_2.license_data[:renewed]).to be false
    end

    it "can only renew a license for Registrant objects" do
      @facility_1.add_service("Renew License")

      expect(@facility_1.renew_drivers_license(@cruz)).to be false
      expect(@facility_1.renew_drivers_license(@registrant_1)).to be true
    end
  end
end
