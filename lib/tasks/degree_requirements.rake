require 'csv'

namespace :degree_requirements do
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

      years = row.headers.select { |k| k =~ /\d{4}-\d{4}/ }
      years.each do |year|
        if row[year].present?
          catalog = Catalog.find_by(slug: year)
          pdf_url = row[year]
          next unless catalog.present? && pdf_url.present?

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
