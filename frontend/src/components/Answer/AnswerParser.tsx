import { cloneDeep } from 'lodash'

import { AskResponse, Citation } from '../../api'

export type ParsedAnswer = {
  citations: Citation[]
  markdownFormatText: string,
  generated_chart: string | null
} | null

export const enumerateCitations = (citations: Citation[]) => {
  const filepathMap = new Map()
  for (const citation of citations) {
    const { filepath } = citation
    let part_i = 1
    if (filepathMap.has(filepath)) {
      part_i = filepathMap.get(filepath) + 1
    }
    filepathMap.set(filepath, part_i)
    citation.part_index = part_i
  }
  return citations
}

export function parseAnswer(answer: AskResponse): ParsedAnswer {
  if (typeof answer.answer !== "string") return null
  let answerText = answer.answer
  
  // Look for both [doc1] format and [1] format citations
  const docCitationLinks = answerText.match(/\[(doc\d\d?\d?)]/g)
  const numericCitationLinks = answerText.match(/\[(\d\d?\d?)]/g)
  
  // Look for full bibliographic citations like "[1] Author, "Title," Year."
  const fullCitationPattern = /\[(\d+)\]\s+[^[]+?(?=\s*\[(\d+)\]|\s*$)/g
  const fullCitations = [...answerText.matchAll(fullCitationPattern)]

  const lengthDocN = '[doc'.length

  let filteredCitations = [] as Citation[]
  let citationReindex = 0

  // Handle [doc1] format citations (existing logic)
  docCitationLinks?.forEach(link => {
    const citationIndex = link.slice(lengthDocN, link.length - 1)
    const citation = cloneDeep(answer.citations[Number(citationIndex) - 1]) as Citation
    if (!filteredCitations.find(c => c.id === citationIndex) && citation) {
      answerText = answerText.replaceAll(link, ` ^${++citationReindex}^ `)
      citation.id = citationIndex // original doc index to de-dupe
      citation.reindex_id = citationReindex.toString() // reindex from 1 for display
      filteredCitations.push(citation)
    }
  })

  // Handle [1] format citations (new logic)
  if (!docCitationLinks && numericCitationLinks && answer.citations.length > 0) {
    numericCitationLinks.forEach(link => {
      const citationIndex = link.slice(1, link.length - 1) // Remove [ and ]
      const citation = cloneDeep(answer.citations[Number(citationIndex) - 1]) as Citation
      if (!filteredCitations.find(c => c.id === citationIndex) && citation) {
        answerText = answerText.replaceAll(link, ` ^${++citationReindex}^ `)
        citation.id = citationIndex // original doc index to de-dupe
        citation.reindex_id = citationReindex.toString() // reindex from 1 for display
        filteredCitations.push(citation)
      }
    })
  }

  // Handle full bibliographic citations embedded in text
  if (!docCitationLinks && !numericCitationLinks && fullCitations.length > 0) {
    fullCitations.forEach(match => {
      const citationNumber = match[1]
      const fullCitationText = match[0]
      
      // Create a synthetic citation object from the text
      const citation: Citation = {
        id: citationNumber,
        content: fullCitationText,
        title: fullCitationText,
        filepath: null,
        url: null,
        metadata: null,
        chunk_id: citationNumber,
        reindex_id: citationNumber,
        part_index: Number(citationNumber)
      }
      
      if (!filteredCitations.find(c => c.id === citationNumber)) {
        answerText = answerText.replace(fullCitationText, ` ^${citationNumber}^ `)
        filteredCitations.push(citation)
      }
    })
  }

  filteredCitations = enumerateCitations(filteredCitations)

  return {
    citations: filteredCitations,
    markdownFormatText: answerText,
    generated_chart: answer.generated_chart
  }
}
