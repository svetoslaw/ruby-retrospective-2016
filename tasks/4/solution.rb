RSpec.describe 'Version' do
  describe 'Argument exception' do
    it 'throws ArgumentError on wrong input' do
      message = "Invalid version string '.3'"
      expect { Version.new('.3') }.to raise_error(ArgumentError, message)

      message = "Invalid version string '1.3.4..'"
      expect { Version.new('1.3.4..') }.to raise_error(ArgumentError, message)

      message = "Invalid version string '0..3'"
      expect { Version.new('0..3') }.to raise_error(ArgumentError, message)
    end
  end
  describe 'Version comparison' do
    it 'compares versions with same number of components' do
      expect(Version.new('')).to eq Version.new

      expect(Version.new('1.3.3')).to eq Version.new('1.3.3')

      expect(Version.new('1.2.3')).to be < Version.new('1.3.3')

      expect(Version.new('2.3.3')).to be > Version.new('1.4.3')
    end

    it 'compares versions with different number of components' do
      expect(Version.new('1.3.3.0')).to eq Version.new('1.3.3')

      expect(Version.new('0.5')).to_not eq Version.new('5')

      expect(Version.new('1.3.3')).to be < Version.new('1.3.3.1')

      expect(Version.new('1.3.3.0.1')).to be < Version.new('1.3.3.1')

      expect(Version.new('1.3')).to be > Version.new('1.2.3')

      expect(Version.new('3')).to be > Version.new('0.3')
    end
  end

  describe 'Version#to_s' do
    it 'transforms version to string' do
      expect(Version.new('').to_s).to eq('')

      expect(Version.new.to_s).to eq('')

      expect(Version.new('30.5').to_s).to eq('30.5')

      expect(Version.new('0.3.5').to_s).to eq('0.3.5')

      expect(Version.new('0.0.5').to_s).to eq('0.0.5')

      expect(Version.new('1.0.5').to_s).to eq('1.0.5')
    end

    it 'transforms version to string and removes ending zeros' do
      expect(Version.new('1.3.0').to_s).to eq('1.3')

      expect(Version.new('1.3.5.0.0').to_s).to eq('1.3.5')
    end
  end

  describe 'Version#components' do
    context 'Version#components without an argument' do
      it 'returns an array with the version components' do
        expect(Version.new('2.4.6').components).to eq([2, 4, 6])

        expect(Version.new('0.4.6').components).to eq([0, 4, 6])
      end

      it 'returns an array with the version components without ending zeros' do 
        expect(Version.new('2.4.0.0').components).to eq([2, 4])

        expect(Version.new('2.4.0.6.0').components).to eq([2, 4, 0, 6])
      end
    end

    context 'Version#components with an argument' do
      it 'returns an array with exact number of components' do
        expect(Version.new('3.5.8').components(3)).to eq([3, 5, 8])
      end

      it 'returns an array with more components' do
        expect(Version.new('3.5.8').components(5)).to eq([3, 5, 8, 0, 0])
      end

      it 'returns an array with less components' do
        expect(Version.new('3.5.8').components(2)).to eq([3, 5])
      end
    end
  end

  describe 'Version::Range' do
    describe 'Range#include?' do
      it 'returns true if version is within range' do
        range = Version::Range.new('1.0.0', '3.0.0')
        version = Version.new('2.0.0')
        expect(range.include?(version)).to eq true

        range = Version::Range.new('1.3.5', '3.5.8')
        version = Version.new('1.3.5')
        expect(range.include?(version)).to eq true

        range = Version::Range.new('1.0.0', '2')
        version = Version.new('1.5')
        expect(range.include?(version)).to be true

        range = Version::Range.new('1.10.5', '2.3.6.1')
        version = Version.new('2.3.5')
        expect(range.include?(version)).to eq true
      end

      it 'returns false if version is not withing range' do
        range = Version::Range.new('1.0.0', '2.0.0')
        version = Version.new('3.0.0')
        expect(range.include?(version)).to eq false

        range = Version::Range.new('1.3.5', '1.3.5')
        version = Version.new('1.3.5')
        expect(range.include?(version)).to eq false

        range = Version::Range.new('1.0.0', '2.0.0')
        version = Version.new('2.0.0')
        expect(range.include?(version)).to eq false
      end
    end

    describe 'Range#to_a' do
      context 'begining version is equal to ending version' do
        it 'returns an empty array' do
          version_1 = Version.new('3.5.8')
          version_2 = Version.new('3.5.8')
          range = Version::Range.new(version_1, version_2)
          expect(range.to_a).to eq([])

          version_1 = Version.new('3.0')
          version_2 = Version.new('3.0.0')
          range = Version::Range.new(version_1, version_2)
          expect(range.to_a).to eq([])
        end
      end

      context 'begining version is not equal to ending version' do
        it 'returns an array with versions between' do
          version_1 = Version.new('3.4.8')
          version_2 = Version.new('3.5.8')
          range = Version::Range.new(version_1, version_2)
          result = [
            '3.4.8', '3.4.9', '3.5.0', '3.5.1', '3.5.2', 
            '3.5.3', '3.5.4', '3.5.5', '3.5.6', '3.5.7'
          ]
          expect(range.to_a).to eq(result)

          version_1 = Version.new('3.9')
          version_2 = Version.new('4')
          range = Version::Range.new(version_1, version_2)
          result = [
            '3.9.0', '3.9.1', '3.9.2', '3.9.3', '3.9.4',
            '3.9.5', '3.9.6', '3.9.7', '3.9.8', '3.9.9'
          ]
          expect(range.to_a).to eq(result)

          version_1 = Version.new('1.9.5')
          version_2 = Version.new('2.0.3')
          range = Version::Range.new(version_1, version_2)
          result = [
            '1.9.5', '1.9.6', '1.9.7', '1.9.8', '1.9.9',
            '2.0.0', '2.0.1', '2.0.2'
          ]
          expect(range.to_a).to eq(result)
        end
      end
    end
  end
end