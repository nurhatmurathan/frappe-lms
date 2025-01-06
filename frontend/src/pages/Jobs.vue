<template>
	<div class="">
		<header
			class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
		>
			<Breadcrumbs
				class="h-7"
				:items="[{ label: __('Вакансии'), route: { name: 'Jobs' } }]"
			/>
			<div class="flex space-x-2">
				<div class="w-40 md:w-44">
					<FormControl
						v-model="jobType"
						type="select"
						:options="jobTypes"
						:placeholder="__('Тип')"
					/>
				</div>
				<div class="w-28 md:w-36">
					<FormControl type="text" placeholder="Поиск" v-model="searchQuery">
						<template #prefix>
							<Search class="w-4 h-4 stroke-1.5 text-gray-600" name="search" />
						</template>
					</FormControl>
				</div>
				<router-link
					v-if="user.data?.name"
					:to="{
						name: 'JobCreation',
						params: {
							jobName: 'new',
						},
					}"
				>
					<Button variant="solid">
						<template #prefix>
							<Plus class="w-4 h-4" />
						</template>
						{{ __('Новая вакансия') }}
					</Button>
				</router-link>
			</div>
		</header>
		<div v-if="jobsList?.length">
			<div class="p-5 mx-auto lg:w-3/4">
				<div class="mb-5 text-xl font-semibold">
					{{ __('Найдите идеальную работу для себя') }}
				</div>
				<div v-for="job in jobsList" class="divide-y">
					<router-link
						:to="{
							name: 'JobDetail',
							params: { job: job.name },
						}"
						:key="job.name"
					>
						<JobCard :job="job" />
					</router-link>
				</div>
			</div>
		</div>
		<div v-else class="p-5 mx-auto italic text-gray-700 w-fit">
			{{ __('Нет опубликованных вакансий') }}
		</div>
	</div>
</template>
<script setup>
import JobCard from '@/components/JobCard.vue'
import { updateDocumentTitle } from '@/utils'
import { Breadcrumbs, Button, createResource, FormControl } from 'frappe-ui'
import { Plus, Search } from 'lucide-vue-next'
import { computed, inject, onMounted, ref } from 'vue'

const user = inject('$user')
const jobType = ref(null)
const searchQuery = ref('')

onMounted(() => {
	let queries = new URLSearchParams(location.search)
	if (queries.has('type')) {
		jobType.value = queries.get('type')
	}
})

const jobs = createResource({
	url: 'lms.lms.api.get_job_opportunities',
	cache: ['jobs'],
	auto: true,
})

const pageMeta = computed(() => {
	return {
		title: 'Jobs',
		description: 'An open job board for the community',
	}
})

const jobsList = computed(() => {
	let jobData = jobs.data
	if (jobType.value && jobType.value != '') {
		jobData = jobData.filter((job) => job.type == jobType.value)
	}
	if (searchQuery.value) {
		let query = searchQuery.value.toLowerCase()
		jobData = jobData.filter(
			(job) =>
				job.job_title.toLowerCase().includes(query) ||
				job.company_name.toLowerCase().includes(query) ||
				job.location.toLowerCase().includes(query),
		)
	}
	return jobData
})

const jobTypes = computed(() => {
	return [
		'',
		{ label: __('Full Time'), value: 'Full Time' },
		{ label: __('Part Time'), value: 'Part Time' },
		{ label: __('Contract'), value: 'Contract' },
		{ label: __('Freelance'), value: 'Freelance' },
	]
})

updateDocumentTitle(pageMeta)
</script>
