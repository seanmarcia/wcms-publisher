require 'csv'

namespace :degree_requirements do
  catalogs = {
    '2011-2012' => '54089fc77275626e8b030000',
    '2012-2013' => '54089fee7275626e8b060000',
    '2013-2014' => '5408a0117275626e8b0a0000',
    '2014-2015' => '5408a03f72756223d7180000',
    '2015-2016' => '5515c92f7275621c23210000',
    '2016-2017' => '56feb726121567610cd2b196',
  }

  years = [
    '2011-2012',
    '2012-2013',
    '2013-2014',
    '2014-2015',
    '2015-2016',
    '2016-2017',
  ]

  desc 'import degree requirements'
  task import: [:environment] do
    path = "./tmp/degree_requirements.csv"
    CSV.foreach(path, {headers: :first_row}) do |row|
      import_row(row)
    end
  end

  def import_row(row)
    begin
      # Lookup by slug or ID
      academic_program = AcademicProgram.find(row['AcademicProgramID'])
    rescue
      puts "Could not find Academic Program matching '#{row['AcademicProgramID']}'"
    end


    if academic_program
      concentration = nil

      if row['Concentration'] == "TRUE"
        if row['ConcentrationID'].present?
          # Lookup by slug or ID
          concentration = academic_program.concentrations.where(
            { "$or" => [ {_id: row['ConcentrationID']}, {slug: row['ConcentrationID']} ] }
          ).first
        else
          # Lookup by title
          concentration ||= academic_program.concentrations.where(title: row['title']).first

          if concentration.blank?
            # create concentration if you can't find it
            concentration = academic_program.concentrations.create(title: row['title'])
          end
        end
      end

      years.each do |year|
        if row[year].present?
          catalog = Catalog.find(catalogs[year])
          pdf_url = row[year]

          degree_requirement = DegreeRequirement.where({
            academic_program: academic_program,
            concentration: concentration,
            catalog: catalog,
            code: row['code'],
            level: row['level']
          }).first_or_initialize


          title = [academic_program.discipline, concentration.try(:title), row['category'].presence.try(:titleize), year].compact.join(": ")

          if !degree_requirement.persisted?
            # only update new degree requirements
            degree_requirement.grouping ||= academic_program.discipline
            degree_requirement.save
          end

          # Import attachment
          attachment = Attachment.where({
            attachable_type: "DegreeRequirement",
            attachable_id: degree_requirement.id,
            metadata: {"category"=>row['category'].to_s}
          }).first_or_initialize

          # For some reason metadata doesn't when you call first_or_initialize
          attachment.metadata = {"category"=>row['category'].to_s}
          # Overwrite name so everything is consistent
          attachment.name = title

          if !attachment.persisted?
            attachment.remote_attachment_url = pdf_url
          end

          attachment.save

          puts "Processed: #{title}"
        end
      end
    else
      puts "Skipped: #{row}"
    end
  end
end
