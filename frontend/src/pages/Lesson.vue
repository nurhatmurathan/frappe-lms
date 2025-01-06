<template>
	<div v-if="lesson.data" class="">
		<header
			class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
		>
			<Breadcrumbs class="h-7" :items="breadcrumbs" />
		</header>
		<div class="grid md:grid-cols-[70%,30%] h-screen">
			<div
				v-if="lesson.data.no_preview"
				class="px-5 pt-10 pb-10 text-center border-r md:px-0"
			>
				<p class="mb-4">
					{{
						__(
							'Этот урок недоступен для предварительного просмотра. Пожалуйста, запишитесь на курс, чтобы получить доступ.',
						)
					}}
				</p>
				<Button v-if="user.data" @click="enrollStudent()" variant="solid">
					{{ __('Начать обучение') }}
				</Button>
				<Button v-else @click="redirectToLogin()">
					{{ __('Войти') }}
				</Button>
			</div>
			<div v-else class="container px-5 pt-5 pb-10 border-r">
				<div class="flex flex-col justify-between md:flex-row md:items-center">
					<div class="text-3xl font-semibold">
						{{ lesson.data.title }}
					</div>
					<div class="flex items-center mt-2 md:mt-0">
						<router-link
							v-if="lesson.data.prev"
							:to="{
								name: 'Lesson',
								params: {
									courseName: courseName,
									chapterNumber: lesson.data.prev.split('.')[0],
									lessonNumber: lesson.data.prev.split('.')[1],
								},
							}"
						>
							<Button class="mr-2">
								<template #prefix>
									<ChevronLeft class="w-4 h-4 stroke-1" />
								</template>
								<span>
									{{ __('Предыдущий') }}
								</span>
							</Button>
						</router-link>
						<router-link
							v-if="allowEdit()"
							:to="{
								name: 'LessonForm',
								params: {
									courseName: courseName,
									chapterNumber: props.chapterNumber,
									lessonNumber: props.lessonNumber,
								},
							}"
						>
							<Button class="mr-2">
								{{ __('Редактировать') }}
							</Button>
						</router-link>
						<router-link
							v-if="lesson.data.next"
							:to="{
								name: 'Lesson',
								params: {
									courseName: courseName,
									chapterNumber: lesson.data.next.split('.')[0],
									lessonNumber: lesson.data.next.split('.')[1],
								},
							}"
						>
							<Button>
								<template #suffix>
									<ChevronRight class="w-4 h-4 stroke-1" />
								</template>
								<span>
									{{ __('Следующий') }}
								</span>
							</Button>
						</router-link>
						<router-link
							v-else
							:to="{
								name: 'CourseDetail',
								params: { courseName: courseName },
							}"
						>
							<Button>
								{{ __('Назад к курсу') }}
							</Button>
						</router-link>
					</div>
				</div>

				<div class="flex items-center mt-2">
					<span
						class="h-6 mr-1"
						:class="{
							'avatar-group overlap': lesson.data.instructors?.length > 1,
						}"
					>
						<UserAvatar
							v-for="instructor in lesson.data.instructors"
							:user="instructor"
						/>
					</span>
					<CourseInstructors
						v-if="lesson.data?.instructors"
						:instructors="lesson.data.instructors"
					/>
				</div>
				<div
					v-if="
						lesson.data.instructor_content &&
						JSON.parse(lesson.data.instructor_content)?.blocks?.length > 1 &&
						allowInstructorContent()
					"
					class="p-3 mt-6 bg-gray-100 rounded-md"
				>
					<div class="font-medium text-gray-600">
						{{ __('Заметки инструктора') }}
					</div>
					<div
						id="instructor-content"
						class="ProseMirror prose prose-table:table-fixed prose-td:p-2 prose-th:p-2 prose-td:border prose-th:border prose-td:border-gray-300 prose-th:border-gray-300 prose-td:relative prose-th:relative prose-th:bg-gray-100 prose-sm max-w-none !whitespace-normal"
					></div>
				</div>
				<div
					v-else-if="lesson.data.instructor_notes"
					class="ProseMirror prose prose-table:table-fixed prose-td:p-2 prose-th:p-2 prose-td:border prose-th:border prose-td:border-gray-300 prose-th:border-gray-300 prose-td:relative prose-th:relative prose-th:bg-gray-100 prose-sm max-w-none !whitespace-normal mt-6"
				>
					<LessonContent :content="lesson.data.instructor_notes" />
				</div>
				<div
					v-if="lesson.data.content"
					class="ProseMirror prose prose-table:table-fixed prose-td:p-2 prose-th:p-2 prose-td:border prose-th:border prose-td:border-gray-300 prose-th:border-gray-300 prose-td:relative prose-th:relative prose-th:bg-gray-100 prose-sm max-w-none !whitespace-normal mt-5"
				>
					<div id="editor"></div>
				</div>
				<div
					v-else
					class="ProseMirror prose prose-table:table-fixed prose-td:p-2 prose-th:p-2 prose-td:border prose-th:border prose-td:border-gray-300 prose-th:border-gray-300 prose-td:relative prose-th:relative prose-th:bg-gray-100 prose-sm max-w-none !whitespace-normal mt-5"
				>
					<LessonContent
						v-if="lesson.data?.body"
						:content="lesson.data.body"
						:youtube="lesson.data.youtube"
						:quizId="lesson.data.quiz_id"
					/>
				</div>
				<div class="mt-20">
					<Discussions
						v-if="allowDiscussions"
						:title="'Вопросы'"
						:doctype="'Course Lesson'"
						:docname="lesson.data.name"
						:key="lesson.data.name"
					/>
				</div>
			</div>
			<div class="sticky top-10">
				<div class="px-2 py-5 border-b bg-gray-50">
					<div class="text-lg font-semibold">
						{{ lesson.data.course_title }}
					</div>
					<div v-if="user && lesson.data.membership" class="mt-3 text-sm">
						{{ Math.ceil(lessonProgress) }}% {{ __('завершено') }}
					</div>

					<ProgressBar
						v-if="user && lesson.data.membership"
						:progress="lessonProgress"
					/>
				</div>
				<CourseOutline
					:courseName="courseName"
					:key="chapterNumber"
					:getProgress="lesson.data.membership ? true : false"
				/>
			</div>
		</div>
	</div>
</template>
<script setup>
import CourseInstructors from '@/components/CourseInstructors.vue'
import CourseOutline from '@/components/CourseOutline.vue'
import Discussions from '@/components/Discussions.vue'
import LessonContent from '@/components/LessonContent.vue'
import ProgressBar from '@/components/ProgressBar.vue'
import UserAvatar from '@/components/UserAvatar.vue'
import EditorJS from '@editorjs/editorjs'
import { Breadcrumbs, Button, createResource } from 'frappe-ui'
import { ChevronLeft, ChevronRight } from 'lucide-vue-next'
import { computed, inject, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getEditorTools, updateDocumentTitle } from '../utils'

const user = inject('$user')
const router = useRouter()
const route = useRoute()
const allowDiscussions = ref(false)
const editor = ref(null)
const instructorEditor = ref(null)
const lessonProgress = ref(0)
const timer = ref(0)
let timerInterval

const props = defineProps({
	courseName: {
		type: String,
		required: true,
	},
	chapterNumber: {
		type: String,
		required: true,
	},
	lessonNumber: {
		type: String,
		required: true,
	},
})

onMounted(() => {
	startTimer()
})

const lesson = createResource({
	url: 'lms.lms.utils.get_lesson',
	cache: ['lesson', props.courseName, props.chapterNumber, props.lessonNumber],
	makeParams(values) {
		return {
			course: props.courseName,
			chapter: values ? values.chapter : props.chapterNumber,
			lesson: values ? values.lesson : props.lessonNumber,
		}
	},
	auto: true,
	onSuccess(data) {
		if (Object.keys(data).length === 0) {
			router.push({
				name: 'CourseDetail',
				params: { courseName: props.courseName },
			})
			return
		}
		lessonProgress.value = data.membership?.progress
		if (data.content) editor.value = renderEditor('editor', data.content)
		if (
			data.instructor_content &&
			JSON.parse(data.instructor_content)?.blocks?.length > 1
		)
			instructorEditor.value = renderEditor(
				'instructor-content',
				data.instructor_content,
			)
		editor.value?.isReady.then(() => {
			checkIfDiscussionsAllowed()
		})

		if (!editor.value && data.body) {
			const quizRegex = /\{\{ Quiz\(".*"\) \}\}/
			const hasQuiz = quizRegex.test(data.body)
			if (!hasQuiz) allowDiscussions.value = true
		}
	},
})

const renderEditor = (holder, content) => {
	// empty the holder
	if (document.getElementById(holder))
		document.getElementById(holder).innerHTML = ''
	return new EditorJS({
		holder: holder,
		tools: getEditorTools(),
		data: JSON.parse(content),
		readOnly: true,
		defaultBlock: 'embed', // editor adds an empty block at the top, so to avoid that added default block as embed
	})
}

const markProgress = () => {
	if (user.data && lesson.data && !lesson.data.progress) {
		progress.submit()
	}
}

const progress = createResource({
	url: 'lms.lms.doctype.course_lesson.course_lesson.save_progress',
	makeParams() {
		return {
			lesson: lesson.data.name,
			course: props.courseName,
		}
	},
	onSuccess(data) {
		lessonProgress.value = data
	},
})

const breadcrumbs = computed(() => {
	let items = [{ label: 'Курсы', route: { name: 'Courses' } }]
	items.push({
		label: lesson?.data?.course_title,
		route: { name: 'CourseDetail', params: { courseName: props.courseName } },
	})
	items.push({
		label: lesson?.data?.title,
		route: {
			name: 'Lesson',
			params: {
				courseName: props.courseName,
				chapterNumber: props.chapterNumber,
				lessonNumber: props.lessonNumber,
			},
		},
	})
	return items
})

watch(
	[() => route.params.chapterNumber, () => route.params.lessonNumber],
	(
		[newChapterNumber, newLessonNumber],
		[oldChapterNumber, oldLessonNumber],
	) => {
		if (newChapterNumber || newLessonNumber) {
			editor.value = null
			instructorEditor.value = null
			allowDiscussions.value = false
			lesson.submit({
				chapter: newChapterNumber,
				lesson: newLessonNumber,
			})
			clearInterval(timerInterval)
			timer.value = 0
			startTimer()
		}
	},
)

const startTimer = () => {
	timerInterval = setInterval(() => {
		timer.value++
		if (timer.value == 30) {
			clearInterval(timerInterval)
			markProgress()
		}
	}, 1000)
}

onBeforeUnmount(() => {
	clearInterval(timerInterval)
})

const checkIfDiscussionsAllowed = () => {
	let quizPresent = false
	JSON.parse(lesson.data?.content)?.blocks?.forEach((block) => {
		if (block.type === 'quiz') quizPresent = true
	})

	if (
		!quizPresent &&
		(lesson.data?.membership ||
			user.data?.is_moderator ||
			user.data?.is_instructor)
	)
		allowDiscussions.value = true
}

const allowEdit = () => {
	if (user.data?.is_moderator) return true
	if (lesson.data?.instructors?.includes(user.data?.name)) return true
	return false
}

const allowInstructorContent = () => {
	if (user.data?.is_moderator) return true
	if (lesson.data?.instructors?.includes(user.data?.name)) return true
	return false
}

const enrollment = createResource({
	url: 'frappe.client.insert',
	makeParams() {
		return {
			doc: {
				doctype: 'LMS Enrollment',
				course: props.courseName,
				member: user.data?.name,
			},
		}
	},
})

const enrollStudent = () => {
	enrollment.submit(
		{},
		{
			onSuccess() {
				window.location.reload()
			},
		},
	)
}

const redirectToLogin = () => {
	window.location.href = `/login?redirect-to=/lms/courses/${props.courseName}`
}

const pageMeta = computed(() => {
	return {
		title: lesson.data?.title,
		description: lesson.data?.course,
	}
})

updateDocumentTitle(pageMeta)
</script>
<style>
.avatar-group {
	display: inline-flex;
	align-items: center;
}

.avatar-group .avatar {
	transition: margin 0.1s ease-in-out;
}

.lesson-content p {
	margin-bottom: 1rem;
	line-height: 1.7;
}

.lesson-content li {
	line-height: 1.7;
}

.lesson-content ol {
	list-style: auto;
	margin: revert;
	padding: 1rem;
}

.lesson-content ul {
	list-style: auto;
	padding: 1rem;
	margin: revert;
}

.lesson-content img {
	border: 1px solid theme('colors.gray.200');
	border-radius: 0.5rem;
}

.lesson-content code {
	display: block;
	overflow-x: auto;
	padding: 1rem 1.25rem;
	background: #011627;
	color: #d6deeb;
	border-radius: 0.5rem;
	margin: 1rem 0;
}

.lesson-content a {
	color: theme('colors.gray.900');
	text-decoration: underline;
	font-weight: 500;
}

.embed-tool__caption {
	display: none;
}

.ce-block__content {
	max-width: unset;
}

.codex-editor__redactor {
	padding-bottom: 0px !important;
}

.codeBoxHolder {
	display: flex;
	flex-direction: column;
	justify-content: flex-start;
	align-items: flex-start;
}

.codeBoxTextArea {
	width: 100%;
	min-height: 30px;
	padding: 10px;
	border-radius: 2px 2px 2px 0;
	border: none !important;
	outline: none !important;
	font: 14px monospace;
}

.codeBoxSelectDiv {
	display: flex;
	flex-direction: column;
	justify-content: flex-start;
	align-items: flex-start;
	position: relative;
}

.codeBoxSelectInput {
	border-radius: 0 0 20px 2px;
	padding: 2px 26px;
	padding-top: 0;
	padding-right: 0;
	text-align: left;
	cursor: pointer;
	border: none !important;
	outline: none !important;
}

.codeBoxSelectDropIcon {
	position: absolute !important;
	left: 10px !important;
	bottom: 0 !important;
	width: unset !important;
	height: unset !important;
	font-size: 16px !important;
}

.codeBoxSelectPreview {
	display: none;
	flex-direction: column;
	justify-content: flex-start;
	align-items: flex-start;
	border-radius: 2px;
	box-shadow: 0 3px 15px -3px rgba(13, 20, 33, 0.13);
	position: absolute;
	top: 100%;
	margin: 5px 0;
	max-height: 30vh;
	overflow-x: hidden;
	overflow-y: auto;
	z-index: 10000;
}

.codeBoxSelectItem {
	width: 100%;
	padding: 5px 20px;
	margin: 0;
	cursor: pointer;
}

.codeBoxSelectItem:hover {
	opacity: 0.7;
}

.codeBoxSelectedItem {
	background-color: lightblue !important;
}

.codeBoxShow {
	display: flex !important;
}

.dark {
	color: #abb2bf;
	background-color: #282c34;
}

.light {
	color: #383a42;
	background-color: #fafafa;
}

.codeBoxTextArea {
	line-height: 1.7;
}

iframe {
	border-top: 3px solid theme('colors.gray.700');
	border-bottom: 3px solid theme('colors.gray.700');
}
</style>
