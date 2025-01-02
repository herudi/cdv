module cdv

// format pdf in inci
fn format_pdf(format string) []f64 {
	return match format {
		'A0' { [33.1102, 46.811] }
		'A1' { [23.3858, 33.1102] }
		'A2' { [16.5354, 23.3858] }
		'A3' { [11.6929, 16.5354] }
		'A4' { [8.2677, 11.6929] }
		'A5' { [5.8268, 8.2677] }
		'A6' { [4.1339, 5.8268] }
		'letter' { [8.5, 11.0] }
		'legal' { [8.5, 14.0] }
		'ledger' { [17.0, 11.0] }
		'tabloid' { [11.0, 17.0] }
		else { [8.5, 11.0] }
	}
}

@[params]
pub struct PDFParams {
pub:
	landscape                 ?bool
	display_header_footer     ?bool @[json: 'displayHeaderFooter']
	print_background          ?bool @[json: 'printBackground']
	scale                     ?f64
	paper_width               ?f64    @[json: 'paperWidth']
	paper_height              ?f64    @[json: 'paperHeight']
	margin_top                ?f64    @[json: 'marginTop']
	margin_bottom             ?f64    @[json: 'marginBottom']
	margin_left               ?f64    @[json: 'marginLeft']
	margin_right              ?f64    @[json: 'marginRight']
	page_ranges               ?string @[json: 'pageRanges']
	header_template           ?string @[json: 'headerTemplate']
	footer_template           ?string @[json: 'footerTemplate']
	prefer_css_page_size      ?bool   @[json: 'preferCSSPageSize']
	transfer_mode             ?string @[json: 'transferMode']
	generate_tagged_pdf       ?bool   @[json: 'generateTaggedPDF']
	generate_document_outline ?bool   @[json: 'generateDocumentOutline']
	format                    string  @[json: '-']
}

pub struct PDF {
pub:
	data   string
	stream ?string
}

pub fn (mut page Page) print_to_pdf_opt(opts PDFParams) !PDF {
	size := format_pdf(opts.format)
	paper_width := opts.paper_width or { size[0] }
	paper_height := opts.paper_height or { size[1] }
	params := struct_to_map(PDFParams{
		...opts
		paper_width:  paper_width
		paper_height: paper_height
	})!.as_map()
	res := page.send('Page.printToPDF', params: params)!.result
	if data := res['data'] {
		if stream := res['stream'] {
			return PDF{data.str(), stream.str()}
		}
		return PDF{
			data: data.str()
		}
	}
	return error('data not found')
}

pub fn (mut page Page) print_to_pdf(opts PDFParams) PDF {
	return page.print_to_pdf_opt(opts) or { page.noop(err) }
}

pub fn (mut page Page) save_as_pdf(path string, opts PDFParams) {
	pdf := page.print_to_pdf(opts)
	pdf.save(path) or { page.noop(err) }
}

pub fn (pdf PDF) save(path string) ! {
	save_data(path, pdf.data)!
}
