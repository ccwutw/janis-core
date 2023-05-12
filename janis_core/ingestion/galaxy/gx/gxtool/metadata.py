



from dataclasses import dataclass
from typing import Optional, Tuple
from janis_core.ingestion.galaxy.utils.general import global_align

from .requirements.model import ContainerRequirement, CondaRequirement
from .citations import Citation


Requirement = ContainerRequirement | CondaRequirement

@dataclass
class ToolXMLMetadata:
    name: str
    id: str
    version: str
    description: str
    help: str
    requirements: list[Requirement]
    citations: list[Citation]
    creator: Optional[str] = None
    url: Optional[str] = None
    owner: Optional[str] = None

    def set_url(self, owner: str) -> None:
        self.owner = owner

    def set_owner(self, owner: str) -> None:
        self.owner = owner

    @property 
    def versioned_id(self) -> str:
        return f'{self.id}-{self.version}'

    @property
    def main_requirement(self) -> Optional[Requirement]:
        """
        sets the main tool requirement
        if no requirements parsed, sets to tool info
        else, sets from the parsed requirements. 
        method:
            - align each requirement to the tool id
            - pick the one with best alignment score
        """
        if len(self.requirements) == 0:
            return None
        
        similarity_scores = self.get_req_similarity_scores()
        similarity_scores.sort(key=lambda x: x[1], reverse=True)
        main_requirement: Requirement = similarity_scores[0][0]
        return main_requirement

    def get_req_similarity_scores(self) -> list[Tuple[Requirement, float]]:
        scores: list[Tuple[Requirement, float]] = []
        for req in self.requirements:
            similarity = global_align(req.name, self.id)
            scores.append((req, similarity))
        return scores

    @property
    def main_citation(self) -> str:
        biotools_citations = [x for x in self.citations if x.type == 'biotools']
        doi_citations = [x for x in self.citations if x.type == 'doi']
        bibtex_citations = [x for x in self.citations if x.type == 'bibtex']
        if biotools_citations:
            return biotools_citations[0].text
        elif doi_citations:
            return doi_citations[0].text
        elif bibtex_citations:
            return bibtex_citations[0].text
        return 'tool xml missing citation'

    @property
    def doi_citation(self) -> Optional[str]:
        doi_citations = [x for x in self.citations if x.type == 'doi']
        if len(doi_citations) > 0:
            return doi_citations[0].text
        return None


