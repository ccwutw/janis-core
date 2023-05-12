
# from janis_core.ingestion.galaxy.logs import logging

from typing import Optional

from janis_core.ingestion.galaxy.gx.gxtool.requirements.model import Requirement, CondaRequirement, ContainerRequirement

from .Container import Container

from .fetching.Fetcher import Fetcher
from .fetching.ContainerReqFetcher import ContainerReqFetcher
from .fetching.QuayIOFetcher import QuayIOFetcher
from .selection.selection import select_best_container_match

DEFAULT_CONTAINER = Container({
    'image_type': 'docker',
    'repo': 'python',
    'tag': '3.7.16',
    'uri': 'quay.io/biocontainers/python:3.7.16',
    '_timestamp': 'Tue, 1 Mar 2022 18:45:00 -0000',
})

# def _fetch_presets(requirement: Requirement) -> list[Container]:
#     return get_images_preset(requirement)

def fetch_online(requirement: Requirement) -> Optional[Container]:
    strategy = _select_strategy(requirement)
    containers = strategy.fetch(requirement)
    if containers:
        container = select_best_container_match(containers, requirement)
        return container
    
def _select_strategy(requirement: Requirement) -> Fetcher:
    match requirement:
        case CondaRequirement():
            return QuayIOFetcher()
        #case CondaRequirement():
        #    return GA4GHFetcher()
        case ContainerRequirement():
            return ContainerReqFetcher()
        case _:
            raise RuntimeError()
    

