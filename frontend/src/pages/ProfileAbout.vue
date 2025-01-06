<template>
	<div class="mb-10 mt-7">
		<h2 class="mb-3 text-lg font-semibold text-gray-900">
			{{ __('About') }}
		</h2>
		<div
			v-if="profile.data.bio"
			v-html="profile.data.bio"
			class="ProseMirror prose prose-table:table-fixed prose-td:p-2 prose-th:p-2 prose-td:border prose-th:border prose-td:border-gray-300 prose-th:border-gray-300 prose-td:relative prose-th:relative prose-th:bg-gray-100 prose-sm max-w-none !whitespace-normal"
		></div>
		<div v-else class="text-sm italic text-gray-700">
			{{ __('No introduction') }}
		</div>
	</div>
	<div class="mb-10 mt-7" v-if="badges.data?.length">
		<h2 class="mb-3 text-lg font-semibold text-gray-900">
			{{ __('Achievements') }}
		</h2>
		<div class="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-5">
			<div v-for="badge in badges.data">
				<Popover trigger="hover" :leaveDelay="Number(0.01)">
					<template #target>
						<div class="relative">
							<img
								:src="badge.badge_image"
								:alt="badge.badge"
								class="h-[80px]"
							/>
							<div
								v-if="badge.count > 1"
								class="absolute bottom-0 right-0 flex items-end p-2 text-xs font-semibold bg-gray-100 rounded-full"
							>
								<span>
									<X class="w-3 h-3" />
								</span>
								{{ badge.count }}
							</div>
						</div>
					</template>
					<template #body-main>
						<div class="w-[250px] text-base">
							<img
								:src="badge.badge_image"
								:alt="badge.badge"
								class="bg-gray-100 rounded-t-md h-[200px] mx-auto"
							/>
							<div class="p-5">
								<div class="mb-2 text-2xl font-semibold">
									{{ badge.badge }}
								</div>
								<div class="mb-4 leading-5">
									{{ badge.badge_description }}
								</div>
								<div class="flex flex-col mb-4">
									<span class="mb-1 text-xs font-medium text-gray-700">
										{{ __('Issued on') }}:
									</span>
									{{ dayjs(badge.issued_on).format('DD MMM YYYY') }}
								</div>
								<div class="flex flex-col">
									<span class="mb-1 text-xs font-medium text-gray-700">
										{{ __('Share on') }}:
									</span>
									<div class="flex items-center space-x-2">
										<Button
											variant="outline"
											size="sm"
											@click="shareOnSocial(badge, 'LinkedIn')"
										>
											<template #prefix>
												<LinkedinIcon class="w-3 h-3 text-gray-700" />
											</template>
											<span class="text-xs">
												{{ __('LinkedIn') }}
											</span>
										</Button>
										<Button
											variant="outline"
											size="sm"
											@click="shareOnSocial(badge, 'Twitter')"
										>
											<template #prefix>
												<Twitter class="w-3 h-3 text-gray-700" />
											</template>
											<span class="text-xs">
												{{ __('Twitter') }}
											</span>
										</Button>
									</div>
								</div>
							</div>
						</div>
					</template>
				</Popover>
			</div>
		</div>
	</div>
</template>
<script setup>
import { sessionStore } from '@/stores/session'
import { Button, createResource, Popover } from 'frappe-ui'
import { LinkedinIcon, Twitter, X } from 'lucide-vue-next'
import { inject } from 'vue'

const dayjs = inject('$dayjs')
const { branding } = sessionStore()

const props = defineProps({
	profile: {
		type: Object,
		required: true,
	},
})

const badges = createResource({
	url: 'frappe.client.get_list',
	params: {
		doctype: 'LMS Badge Assignment',
		fields: ['name', 'badge', 'badge_image', 'badge_description', 'issued_on'],
		filters: {
			member: props.profile.data.name,
		},
	},
	auto: true,
	transform(data) {
		let finalBadges = []
		let groupedBadges = Object.groupBy(data, ({ badge }) => badge)
		for (let badge in groupedBadges) {
			let badgeData = groupedBadges[badge][0]
			badgeData.count = groupedBadges[badge].length
			finalBadges.push(badgeData)
		}
		return finalBadges
	},
})

const shareOnSocial = (badge, medium) => {
	let shareUrl
	const url = encodeURIComponent(
		`${window.location.origin}/lms/badges/${badge.badge}/${props.profile.data?.email}`,
	)
	const summary = `I am happy to announce that I earned the ${
		badge.badge
	} badge on ${dayjs(badge.issued_on).format('DD MMM YYYY')} at ${
		branding.data?.app_name
	}.`

	if (medium == 'LinkedIn')
		shareUrl = `https://www.linkedin.com/shareArticle?mini=true&url=${url}&text=${summary}`
	else if (medium == 'Twitter')
		shareUrl = `https://twitter.com/intent/tweet?text=${summary}&url=${url}`

	window.open(shareUrl, '_blank')
}
</script>
